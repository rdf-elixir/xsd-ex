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
    id = Keyword.fetch!(opts, :id) |> iri()

    quote bind_quoted: [], unquote: true do
      @behaviour unquote(__MODULE__)

      defstruct [:value, :uncanonical_lexical]

      alias XSD.Literal

      @id unquote(id)
      @impl unquote(__MODULE__)
      @invalid_value nil

      def id, do: XSD.Datatype.iri(@id)

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
      def lexical(lexical)

      def lexical(%__MODULE__{value: value, uncanonical_lexical: nil}),
        do: canonical_mapping(value)

      def lexical(%__MODULE__{uncanonical_lexical: lexical}), do: lexical

      @impl unquote(__MODULE__)
      def canonical_mapping(value), do: to_string(value)

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
      def valid?(_), do: true

      defoverridable canonical_mapping: 1,
                     init_valid_lexical: 3,
                     init_invalid_lexical: 2
    end
  end
end
