# CAUTION:
# This behaviour shares some functions with the RDF.Literal.Datatype behaviour,
# which must be kept in-sync.

defmodule XSD.Datatype do
  @moduledoc """
  The behaviour of all XSD datatypes.

  A XSD datatype has three properties:

  - A _value space_, which is a set of values.
  - A _lexical space_, which is a set of _literals_ used to denote the values.
  - A small collection of functions associated with the datatype.

  This behaviour is implemented on structs for the literals of the defined datatypes.
  This means the struct values represent a literal

  The small collection of functions associated with the datatype include

  - an equality relation for its value space via the `equal_value?/2` function
    (as opposed to the term equality function `XSD.Literal.equal?/2` function over
    the _lexical space_ of literals)
  - optionally order relations on the _value space_
  - a canonical form ...

  - and a _lexical mapping_, which is a mapping from the _lexical space_ into
    the _value space_

  A `XSD.Datatype` implements the foundational functions for the lexical form,
  the validation, conversion and canonicalization of typed `RDF.Literal`s.
  """

  @type t :: module

  @type uncanonical_lexical :: String.t() | nil

  @type comparison_result :: :lt | :gt | :eq

  @spec base_primitive(t()) :: t()
  def base_primitive(datatype), do: datatype.base_primitive()

  @spec derived_from?(t(), t()) :: boolean
  def derived_from?(datatype, super_datatype), do: datatype.derived_from?(super_datatype)

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

  @doc """
  Returns if the `XSD.Datatype` is a primitive datatype.
  """
  @callback primitive?() :: boolean

  @doc """
  The base datatype from which a `XSD.Datatype` is derived.

  Note: Since this library focuses on atomic types and the special `xsd:anyAtomicType`
  specified as the base type of all primitive types in the W3C spec wouldn't serve any
  purpose here, all primitive datatypes just return `nil`.
  """
  @callback base :: t() | nil

  @doc """
  The primitive `XSD.Datatype` from which a `XSD.Datatype` is derived.

  In case of a primitive `XSD.Datatype` this function returns the this `XSD.Datatype` itself.
  """
  @callback base_primitive :: t()

  @doc """
  Checks if a `XSD.Datatype` is directly or indirectly derived from another `XSD.Datatype`.
  """
  @callback derived_from?(t()) :: boolean

  @doc """
  Checks if the datatype of a given literal is derived from a `XSD.Datatype`.
  """
  @callback derived?(XSD.Literal.t()) :: boolean

  @doc """
  The set of applicable facets of a `XSD.Datatype`.
  """
  @callback applicable_facets :: [XSD.Facet.t()]

  @doc """
  Returns the value of a `XSD.Datatype` literal.
  """
  @callback value(XSD.Literal.t()) :: any

  @doc """
  Returns the lexical form of a `XSD.Datatype` literal.
  """
  @callback lexical(XSD.Literal.t()) :: String.t()

  @doc """
  Produces the canonical representation of a `XSD.Datatype` literal.
  """
  @callback canonical(XSD.Literal.t()) :: XSD.Literal.t()

  @doc """
  Determines if the lexical form of a `XSD.Datatype` literal is the canonical form.
  """
  @callback canonical?(XSD.Literal.t()) :: boolean

  @doc """
  Determines if the lexical form of a `XSD.Datatype` literal is a member of its lexical value space.
  """
  @callback valid?(XSD.Literal.t() | any) :: boolean

  @doc """
  Casts a `XSD.Datatype` literal or coercible value of one type into a `XSD.Datatype` literal of another type.

  If the given literal or value is invalid or can not be converted into this datatype an
  implementation should return `nil`.
  """
  @callback cast(XSD.Literal.t() | any) :: XSD.Literal.t() | nil

  @doc """
  Checks if two `XSD.Datatype` literals are equal in terms of the values of their value space.

  Non-`XSD.Datatype` literals are tried to be coerced via `XSD.Literal.coerce/1` before comparison.

  Returns `nil` when the given arguments are not comparable as literals of this
  datatype. This behaviour is particularly important for SPARQL.ex where this
  function is used for the `=` operator, where comparisons between incomparable
  terms are treated as errors and immediately leads to a rejection of a possible
  match.

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
  @callback compare(XSD.Literal.t() | any, XSD.Literal.t() | any) ::
              comparison_result | :indeterminate | nil

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

  If the Elixir mapping for the given value can not be mapped into value space of
  the XSD datatype an implementation should return `@invalid_value`
  (which is just `nil` at the moment, so `nil` is never a valid value of a value space).

  Otherwise a tuple `{value, lexical}` with `value` being the internal representation
  of the mapped value from the value space and `lexical` being the lexical representation
  to be used for the Elixir value or `nil` if `init_valid_lexical/3` should be used
  to determine the lexical form in general (i.e. also when initialized with a string
  via the `lexical_mapping/2`). Since the later case is most often what you want,
  you can also return `value` directly, as long as it is not a two element tuple.
  """
  @callback elixir_mapping(any, Keyword.t()) :: any | {any, uncanonical_lexical}

  @doc """
  Returns the standard lexical representation for a value of the value space of a `XSD.Datatype`.
  """
  @callback canonical_mapping(any) :: String.t()

  @doc """
  Produces the lexical representation to be used as for a `XSD.Datatype` literal.

  By default the lexical representation of a `XSD.Datatype` is either the
  canonical form in case it is created from a non-string Elixir value or, if it
  is created from a string, just with that string as the lexical form.

  But there can be various reasons for why this should be different for certain
  datatypes. For example, for `XSD.Double`s given as Elixir floats, we want the
  default lexical representation to be the decimal and not the canonical
  exponential form. Another reason might be that additional options are given
  which should be taken into account in the lexical form.

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
    id = Keyword.get(opts, :id)

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
      if unquote(id) do
        def id, do: unquote(id)
      else
        def id, do: target_namespace() <> name()
      end

      @impl unquote(__MODULE__)
      def derived_from?(datatype)

      def derived_from?(__MODULE__), do: true

      def derived_from?(datatype) do
        base = base()
        not is_nil(base) and base.derived_from?(datatype)
      end

      @impl unquote(__MODULE__)
      def derived?(literal), do: XSD.Literal.derived_from?(literal, __MODULE__)

      # Dialyzer causes a warning on all primitives since the facet_conform?/2 call
      # always returns true there, so the other branch is unnecessary. This could
      # be fixed by generating a special version for primitives, but it's not worth
      # maintaining different versions of this function which must be kept in-sync.
      @dialyzer {:nowarn_function, new: 2}
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

      @impl unquote(__MODULE__)
      def value(%__MODULE__{} = literal), do: literal.value

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

      @impl unquote(__MODULE__)
      def canonical?(literal)
      def canonical?(%__MODULE__{uncanonical_lexical: nil}), do: true
      def canonical?(%__MODULE__{}), do: false

      @impl unquote(__MODULE__)
      @spec valid?(t() | any) :: boolean
      def valid?(literal)
      def valid?(%__MODULE__{value: @invalid_value}), do: false
      def valid?(%__MODULE__{}), do: true
      def valid?(_), do: false

      defp validate_cast(%__MODULE__{} = literal), do: if(valid?(literal), do: literal)
      defp validate_cast(_), do: nil

      # TODO: Should the following higher-level helper functions be part of the behaviour?

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
