defmodule XSD.Datatype do
  @moduledoc """
  A behaviour for the definition of XSD datatypes.
  """

  @ns "http://www.w3.org/2001/XMLSchema#"

  @doc """
  Returns to official XSD namespace IRI.

  `"#{@ns}"`
  """
  def ns(), do: @ns

  def iri(datatype), do: @ns <> datatype

  @doc """
  The name of the datatype.
  """
  @callback name :: String.t()

  @doc """
  The IRI of the datatype.
  """
  @callback id :: String.t()

  @doc """
  Determines if the lexical form of a `XSD.Datatype` is a member of its lexical value space.
  """
  @callback valid?(any) :: boolean

  @doc """
  Returns the lexical form of a `XSD.Datatype` value.
  """
  @callback lexical(any) :: String.t()

  @doc """
  Produces the canonical representation of a `XSD.Datatype` value.
  """
  @callback canonical(any) :: any

  @doc """
  Casts a `XSD.Datatype` value of one type into a `XSD.Datatype` value of another type.

  If the given value is invalid or can not be converted into this datatype an
  implementation should return `@invalid_value`.
  """
  @callback cast(any) :: any

  @doc """
  Checks if two value `XSD.Datatype` values are equal.

  The default implementation of the `_using__` macro compares the values of the
  `canonical/1` forms of the given value of this datatype.
  """
  @callback equal_value?(value1 :: any, value2 :: any) :: boolean

  @doc """
  Compares two `XSD.Datatype` values.

  Returns `:gt` if first value is greater than the second in terms of their datatype
  and `:lt` for vice versa. If the two values are equal `:eq` is returned.
  For datatypes with only partial ordering `:indeterminate` is returned when the
  order of the given literals is not defined.

  Returns `nil` when the given arguments are not comparable datatypes or if one
  them is invalid.

  The default implementation of the `_using__` macro compares the values of the
  `canonical/1` forms of the given values of this datatype.
  """
  @callback compare(value1 :: any, value2 :: any) :: :lt | :gt | :eq | :indeterminate | nil

  @doc """
  A mapping from the lexical space of a `XSD.Datatype` into its value space.
  """
  @callback lexical_mapping(String.t(), Keyword.t()) :: any

  @doc """
  A mapping from Elixir values into the value space of a `XSD.Datatype`.
  """
  @callback elixir_mapping(any, Keyword.t()) :: any

  @doc """
  Returns the standard lexical representation for a value of the value space of a `XSD.Datatype`.
  """
  @callback canonical_mapping(any) :: String.t()

  @doc """
  Returns the lexical representation to be used as for a `XSD.Datatype`.

  If the lexical representation for a given `value` and `lexical` should be the
  canonical one, an implementation should return `nil`.
  """
  @callback init_valid_lexical(any, String.t(), Keyword.t()) :: String.t()

  @doc """
  Produces the lexical representation of an invalid value.

  The default implementation of the `_using__` macro just returns `to_string/1`
  representation of the value.
  """
  @callback init_invalid_lexical(any, Keyword.t()) :: String.t()

  defmacro __using__(opts) do
    name = Keyword.fetch!(opts, :name)

    quote bind_quoted: [], unquote: true do
      @behaviour unquote(__MODULE__)

      defstruct [:value, :uncanonical_lexical]

      alias XSD.Literal

      @invalid_value nil

      @name unquote(name)
      @impl unquote(__MODULE__)
      def name, do: @name

      @id XSD.Datatype.iri(@name)
      @impl unquote(__MODULE__)
      def id, do: @id

      def new(value, opts \\ [])

      def new(lexical, opts) when is_binary(lexical) do
        case lexical_mapping(lexical, opts) do
          @invalid_value -> build_invalid(lexical, opts)
          value -> build_valid(value, lexical, opts)
        end
      end

      def new(value, opts) do
        case elixir_mapping(value, opts) do
          @invalid_value -> build_invalid(value, opts)
          {value, lexical} -> build_valid(value, lexical, opts)
          value -> build_valid(value, nil, opts)
        end
      end

      def new!(value, opts \\ []) do
        xsd_value = new(value, opts)

        if valid?(xsd_value) do
          xsd_value
        else
          raise ArgumentError, "#{inspect(value)} is not a valid #{inspect(__MODULE__)}"
        end
      end

      @doc false
      def build_valid(value, lexical, opts) do
        if Keyword.get(opts, :canonicalize) do
          %__MODULE__{value: value}
        else
          initial_lexical = init_valid_lexical(value, lexical, opts)

          %__MODULE__{
            value: value,
            uncanonical_lexical:
              if(initial_lexical && initial_lexical != canonical_mapping(value),
                do: initial_lexical
              )
          }
        end
      end

      defp build_invalid(lexical, opts) do
        %__MODULE__{uncanonical_lexical: init_invalid_lexical(lexical, opts)}
      end

      @impl unquote(__MODULE__)
      def canonical_mapping(value), do: to_string(value)

      @impl unquote(__MODULE__)
      def lexical(lexical)

      def lexical(%__MODULE__{value: value, uncanonical_lexical: nil}),
        do: canonical_mapping(value)

      def lexical(%__MODULE__{uncanonical_lexical: lexical}), do: lexical

      def canonical_lexical(%__MODULE__{value: nil}), do: nil

      def canonical_lexical(%__MODULE__{value: value, uncanonical_lexical: nil}),
        do: canonical_mapping(value)

      def canonical_lexical(%__MODULE__{} = value),
        do: value |> canonical() |> lexical()

      def canonical_lexical(_), do: nil

      @impl unquote(__MODULE__)
      def init_valid_lexical(value, lexical, opts)
      def init_valid_lexical(_value, nil, _opts), do: nil
      def init_valid_lexical(_value, lexical, _opts), do: lexical

      @impl unquote(__MODULE__)
      def init_invalid_lexical(value, _opts), do: to_string(value)

      @impl unquote(__MODULE__)
      def canonical(xsd_value)

      def canonical(%__MODULE__{uncanonical_lexical: nil} = xsd_value), do: xsd_value

      def canonical(%__MODULE__{value: @invalid_value} = xsd_value), do: xsd_value

      def canonical(%__MODULE__{} = xsd_value),
        do: %__MODULE__{xsd_value | uncanonical_lexical: nil}

      @impl unquote(__MODULE__)
      def valid?(xsd_value)
      def valid?(%__MODULE__{value: @invalid_value}), do: false
      def valid?(%__MODULE__{}), do: true
      def valid?(_), do: false

      defp validate_cast(%__MODULE__{} = literal), do: if(valid?(literal), do: literal)
      defp validate_cast(_), do: nil

      @impl unquote(__MODULE__)
      def equal_value?(value1, value2)

      def equal_value?(
            %datatype{uncanonical_lexical: lexical1, value: nil},
            %datatype{uncanonical_lexical: lexical2, value: nil}
          ) do
        lexical1 == lexical2
      end

      def equal_value?(%datatype{} = value1, %datatype{} = value2) do
        canonical(value1).value == canonical(value2).value
      end

      def equal_value?(_, _), do: false

      @impl unquote(__MODULE__)
      def compare(left, right)

      def compare(
            %__MODULE__{value: left_value} = left,
            %__MODULE__{value: right_value} = right
          )
          when not (is_nil(left_value) or is_nil(right_value)) do
        case {canonical(left).value, canonical(right).value} do
          {value1, value2} when value1 < value2 -> :lt
          {value1, value2} when value1 > value2 -> :gt
          _ -> if equal_value?(left, right), do: :eq
        end
      end

      def compare(_, _), do: nil

      def less_than?(literal1, literal2), do: XSD.Value.less_than?(literal1, literal2)

      def greater_than?(literal1, literal2), do: XSD.Value.greater_than?(literal1, literal2)

      defoverridable canonical_mapping: 1,
                     init_valid_lexical: 3,
                     init_invalid_lexical: 2,
                     equal_value?: 2,
                     compare: 2
    end
  end
end
