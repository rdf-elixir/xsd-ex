defmodule XSD.Datatype.Primitive do
  defmacro def_applicable_facet(facet) do
    quote do
      @applicable_facets unquote(facet)
      use unquote(facet)
    end
  end

  defmacro __using__(opts) do
    quote do
      use XSD.Datatype, unquote(opts)

      import unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :applicable_facets, accumulate: true)

      @impl XSD.Datatype
      def base, do: nil

      @impl XSD.Datatype
      def base_primitive, do: __MODULE__

      @impl XSD.Datatype
      def init_valid_lexical(value, lexical, opts)
      def init_valid_lexical(_value, nil, _opts), do: nil
      def init_valid_lexical(_value, lexical, _opts), do: lexical

      @impl XSD.Datatype
      def init_invalid_lexical(value, _opts), do: to_string(value)

      @impl XSD.Datatype
      def canonical_mapping(value), do: to_string(value)

      @impl XSD.Datatype
      def cast(literal_or_value)

      # Invalid values can not be casted in general
      def cast(%{value: @invalid_value}), do: nil

      def cast(%__MODULE__{} = literal), do: literal

      def cast(nil), do: nil

      def cast(value) do
        if XSD.literal?(value) do
          if XSD.Literal.derived_from?(value, __MODULE__) do
            build_valid(value.value, value.uncanonical_lexical, [])
          end
        else
          value |> XSD.Literal.coerce() |> cast()
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
                     cast: 1,
                     init_valid_lexical: 3,
                     init_invalid_lexical: 2,
                     equal_value?: 2,
                     compare: 2

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @impl XSD.Datatype
      def applicable_facets, do: MapSet.new(@applicable_facets)
    end
  end
end
