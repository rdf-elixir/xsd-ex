defmodule XSD.Datatype.Restriction do
  defmacro __using__(opts) do
    base = Keyword.fetch!(opts, :base)

    quote do
      use XSD.Datatype, unquote(opts)

      import XSD.Facet, only: [def_facet_constraint: 2]

      @type valid_value :: unquote(base).valid_value()

      @base unquote(base)
      @impl XSD.Datatype
      @spec base :: XSD.Datatype.t()
      def base, do: @base

      @impl XSD.Datatype
      def base_primitive, do: @base.base_primitive()

      @impl XSD.Datatype
      def applicable_facets, do: @base.applicable_facets()

      @impl XSD.Datatype
      def init_valid_lexical(value, lexical, opts),
        do: @base.init_valid_lexical(value, lexical, opts)

      @impl XSD.Datatype
      def init_invalid_lexical(value, opts),
        do: @base.init_invalid_lexical(value, opts)

      @impl XSD.Datatype
      def lexical_mapping(lexical, opts),
        do: @base.lexical_mapping(lexical, opts)

      @impl XSD.Datatype
      def elixir_mapping(value, opts),
        do: @base.elixir_mapping(value, opts)

      @impl XSD.Datatype
      def canonical_mapping(value),
        do: @base.canonical_mapping(value)

      @impl XSD.Datatype
      def cast(literal_or_value)

      # Invalid values can not be casted in general
      def cast(%{value: @invalid_value}), do: nil

      def cast(%__MODULE__{} = literal), do: literal

      def cast(literal_or_value) do
        # Note: This direct call of the cast/1 implementation of the base_primitive
        # is an optimization to not have go through the whole derivation chain and
        # doing potentially a lot of redundant validations, but this relies on
        # cast/1 not being overridden on restriction.
        case base_primitive().cast(literal_or_value) do
          nil ->
            nil

          %{value: value, uncanonical_lexical: lexical} ->
            if facet_conform?(value, lexical) do
              build_valid(value, lexical, [])
            end
        end
      end

      @impl XSD.Datatype
      def equal_value?(literal1, literal2)

      def equal_value?(
            %datatype{uncanonical_lexical: lexical1, value: nil},
            %datatype{uncanonical_lexical: lexical2, value: nil}
          ) do
        lexical1 == lexical2
      end

      def equal_value?(%datatype{} = literal1, %datatype{} = literal2) do
        canonical(literal1).value == canonical(literal2).value
      end

      def equal_value?(_, _), do: false

      @impl XSD.Datatype
      @spec compare(t, t) :: XSD.Datatype.comparison_result() | :indeterminate | nil
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

      defoverridable canonical_mapping: 1,
                     equal_value?: 2,
                     compare: 2

      Module.register_attribute(__MODULE__, :facets, accumulate: true)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    import XSD.Facet

    restriction_impl(
      Module.get_attribute(env.module, :facets),
      Module.get_attribute(env.module, :base).applicable_facets
    )
  end
end
