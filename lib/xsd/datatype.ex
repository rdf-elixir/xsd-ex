defmodule XSD.Datatype do
  @moduledoc """
  The behaviour of all XSD datatypes.
  """

  @type t :: module

  @type uncanonical_lexical :: String.t() | nil

  @type comparison_result :: :lt | :gt | :eq

  @spec base_primitive(t()) :: XSD.Datatype.t()
  def base_primitive(datatype), do: datatype.base_primitive()

  @spec derived_from?(t(), t()) :: boolean
  def derived_from?(datatype, super_datatype), do: datatype.derived_from?(super_datatype)

  @doc """
  Checks if two `XSD.Datatype`s are comparable.
  """
  @spec comparable?(t(), t()) :: boolean
  def comparable?(datatype1, datatype2)
  def comparable?(datatype, datatype), do: true

  def comparable?(datatype1, datatype2) do
    XSD.datatype?(datatype1) and XSD.datatype?(datatype2) and
      (derived_from?(datatype1, datatype2) or derived_from?(datatype2, datatype1) or
         (XSD.Numeric.datatype?(datatype1) and XSD.Numeric.datatype?(datatype2)))
  end

  @doc """
  The IRI namespace of the `XSD.Datatype`.

  By default the XSD namespace `"http://www.w3.org/2001/XMLSchema#"` for primitive
  datatypes or in case of derived datatypes the `target_namespace/0` of the `base/0` datatype.
  """
  @callback target_namespace :: String.t()

  @doc """
  The name of the `XSD.Datatype`.
  """
  @callback name :: String.t()

  @doc """
  The IRI of the `XSD.Datatype`.

  It is the concatenation of the `c:target_namespace/0` and the `c:name/0`.
  """
  @callback id :: String.t()

  @callback base :: t() | nil

  @callback base_primitive :: t()

  @callback derived_from?(t()) :: boolean

  @callback derived?(XSD.Literal.t()) :: boolean

  @callback applicable_facets :: MapSet.t(XSD.Facet.t())

  @doc """
  Determines if the lexical form of a `XSD.Datatype` literal is a member of its lexical value space.
  """
  @callback valid?(XSD.Literal.t() | any) :: boolean

  @doc """
  Returns the lexical form of a `XSD.Datatype` value.
  """
  @callback lexical(XSD.Literal.t()) :: String.t()

  @doc """
  Produces the canonical representation of a `XSD.Datatype` literal.
  """
  @callback canonical(XSD.Literal.t()) :: XSD.Literal.t()

  @doc """
  Casts a `XSD.Datatype` literal or coercible value of one type into a `XSD.Datatype` literal of another type.

  If the given literal or value is invalid or can not be converted into this datatype an
  implementation should return `nil`.
  """
  @callback cast(XSD.Literal.t() | any) :: XSD.Literal.t() | nil

  @doc """
  Checks if two `XSD.Datatype` literals are equal in terms of the values of their value space.

  Non-`XSD.Datatype` literals are tried to be coerced via `RDF.Term.coerce/1` before comparison.

  The default implementation of the `_using__` macro compares the values of the
  `canonical/1` forms of the given literal of this datatype.
  """
  @callback equal_value?(XSD.Literal.t() | any, XSD.Literal.t() | any) :: boolean

  @doc """
  Compares two `XSD.Datatype` literals.

  Returns `:gt` if value of the first literal is greater than the value of the second in
  terms of their datatype and `:lt` for vice versa. If the two literals are equal `:eq` is returned.
  For datatypes with only partial ordering `:indeterminate` is returned when the
  order of the given literals is not defined.

  Returns `nil` when the given arguments are not comparable datatypes or if one
  them is invalid.

  The default implementation of the `_using__` macro compares the values of the
  `canonical/1` forms of the given literals of this datatype.
  """
  @callback compare(XSD.Literal.t(), XSD.Literal.t()) :: comparison_result | :indeterminate | nil

  @doc """
  Matches the lexical form of the given `XSD.Datatype` literal against a XPath and XQuery regular expression pattern.

  The regular expression language is defined in _XQuery 1.0 and XPath 2.0 Functions and Operators_.

  see <https://www.w3.org/TR/xpath-functions/#func-matches>
  """
  @callback matches?(XSD.Literal.t(), pattern :: String.t()) :: boolean

  @doc """
  Matches the lexical form of the given `XSD.Datatype` literal against a XPath and XQuery regular expression pattern with flags.

  The regular expression language is defined in _XQuery 1.0 and XPath 2.0 Functions and Operators_.

  see <https://www.w3.org/TR/xpath-functions/#func-matches>
  """
  @callback matches?(XSD.Literal.t(), pattern :: String.t(), flags :: String.t()) :: boolean

  @doc """
  A mapping from the lexical space of a `XSD.Datatype` into its value space.
  """
  @callback lexical_mapping(String.t(), Keyword.t()) :: any

  @doc """
  A mapping from Elixir values into the value space of a `XSD.Datatype`.
  """
  @callback elixir_mapping(any, Keyword.t()) :: any | {any, uncanonical_lexical}

  @doc """
  Returns the standard lexical representation for a value of the value space of a `XSD.Datatype`.
  """
  @callback canonical_mapping(any) :: String.t()

  @doc """
  Produces the lexical representation to be used as for a `XSD.Datatype` literal.

  If the lexical representation for a given `value` and `lexical` should be the
  canonical one, an implementation should return `nil`.
  """
  @callback init_valid_lexical(any, uncanonical_lexical, Keyword.t()) :: uncanonical_lexical

  @doc """
  Produces the lexical representation of an invalid value.

  The default implementation of the `_using__` macro just returns `to_string/1`
  representation of the value.
  """
  @callback init_invalid_lexical(any, Keyword.t()) :: String.t()

  defmacro __using__(opts) do
    name = Keyword.fetch!(opts, :name)

    quote do
      @behaviour XSD.Datatype

      defstruct [:value, :uncanonical_lexical]

      @invalid_value nil

      @type invalid_value :: nil
      @type value :: valid_value | invalid_value

      @type t :: %__MODULE__{
              value: value,
              uncanonical_lexical: XSD.Datatype.uncanonical_lexical()
            }

      @name unquote(name)
      @impl unquote(__MODULE__)
      def name, do: @name

      @impl unquote(__MODULE__)
      def id, do: target_namespace() <> name()

      @impl unquote(__MODULE__)
      def derived_from?(datatype)

      def derived_from?(__MODULE__), do: true

      def derived_from?(datatype) do
        base = base()
        not is_nil(base) and base.derived_from?(datatype)
      end

      @impl unquote(__MODULE__)
      def derived?(literal), do: XSD.Literal.derived_from?(literal, __MODULE__)

      @spec new(any, Keyword.t()) :: t()
      def new(value, opts \\ [])

      def new(lexical, opts) when is_binary(lexical) do
        case lexical_mapping(lexical, opts) do
          @invalid_value ->
            build_invalid(lexical, opts)

          value ->
            if facet_conform?(value, lexical) do
              build_valid(value, lexical, opts)
            else
              build_invalid(lexical, opts)
            end
        end
      end

      def new(value, opts) do
        case elixir_mapping(value, opts) do
          @invalid_value ->
            build_invalid(value, opts)

          value ->
            {value, lexical} =
              case value do
                {value, lexical} -> {value, lexical}
                value -> {value, nil}
              end

            if facet_conform?(value, lexical) do
              build_valid(value, lexical, opts)
            else
              build_invalid(value, opts)
            end
        end
      end

      @spec new!(any, Keyword.t()) :: t()
      def new!(value, opts \\ []) do
        literal = new(value, opts)

        if valid?(literal) do
          literal
        else
          raise ArgumentError, "#{inspect(value)} is not a valid #{inspect(__MODULE__)}"
        end
      end

      @doc false
      @spec build_valid(any, XSD.Datatype.uncanonical_lexical(), Keyword.t()) :: t()
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

      @doc false
      def facet_conform?(value, lexical) do
        Enum.all?(applicable_facets(), fn facet ->
          facet.conform?(__MODULE__, value, lexical)
        end)
      end

      @impl unquote(__MODULE__)
      @spec valid?(t() | any) :: boolean
      def valid?(literal)
      def valid?(%__MODULE__{value: @invalid_value}), do: false
      def valid?(%__MODULE__{}), do: true
      def valid?(_), do: false

      defp validate_cast(%__MODULE__{} = literal), do: if(valid?(literal), do: literal)
      defp validate_cast(_), do: nil

      @impl unquote(__MODULE__)
      def lexical(lexical)

      def lexical(%__MODULE__{value: value, uncanonical_lexical: nil}),
        do: canonical_mapping(value)

      def lexical(%__MODULE__{uncanonical_lexical: lexical}), do: lexical

      @impl unquote(__MODULE__)
      @spec canonical(t()) :: t()
      def canonical(literal)

      def canonical(%__MODULE__{uncanonical_lexical: nil} = literal), do: literal

      def canonical(%__MODULE__{value: @invalid_value} = literal), do: literal

      def canonical(%__MODULE__{} = literal),
        do: %__MODULE__{literal | uncanonical_lexical: nil}

      def canonical_lexical(literal)
      def canonical_lexical(%__MODULE__{value: nil}), do: nil

      def canonical_lexical(%__MODULE__{value: value, uncanonical_lexical: nil}),
        do: canonical_mapping(value)

      def canonical_lexical(%__MODULE__{} = literal),
        do: literal |> canonical() |> lexical()

      def canonical_lexical(_), do: nil

      @spec less_than?(t, t) :: boolean
      def less_than?(literal1, literal2), do: XSD.Literal.less_than?(literal1, literal2)

      @spec greater_than?(t, t) :: boolean
      def greater_than?(literal1, literal2), do: XSD.Literal.greater_than?(literal1, literal2)

      @doc """
      Matches the string representation of the given value against a XPath and XQuery regular expression pattern.

      The regular expression language is defined in _XQuery 1.0 and XPath 2.0 Functions and Operators_.

      see <https://www.w3.org/TR/xpath-functions/#func-matches>
      """
      @impl XSD.Datatype
      def matches?(%__MODULE__{} = literal, pattern, flags \\ "") do
        literal
        |> lexical()
        |> XSD.Utils.Regex.matches?(pattern, flags)
      end

      defimpl Inspect do
        def inspect(literal, _opts) do
          "Elixir." <> datatype_name = to_string(literal.__struct__)

          "%#{datatype_name}{value: #{inspect(literal.value)}, lexical: #{
            literal |> literal.__struct__.lexical() |> inspect()
          }}"
        end
      end

      defimpl String.Chars do
        def to_string(literal) do
          literal.__struct__.lexical(literal)
        end
      end
    end
  end
end
