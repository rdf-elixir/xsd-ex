defmodule XSD.Datatype.Definition do
  defmacro __using__(opts) do
    name = Keyword.fetch!(opts, :name)

    quote bind_quoted: [], unquote: true do
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
      @impl XSD.Datatype
      def name, do: @name

      @id XSD.Datatype.iri(@name)
      @impl XSD.Datatype
      def id, do: @id

      @spec new(any, Keyword.t()) :: t()
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

      @impl XSD.Datatype
      def canonical_mapping(value), do: to_string(value)

      @impl XSD.Datatype
      def lexical(lexical)

      def lexical(%__MODULE__{value: value, uncanonical_lexical: nil}),
        do: canonical_mapping(value)

      def lexical(%__MODULE__{uncanonical_lexical: lexical}), do: lexical

      def canonical_lexical(%__MODULE__{value: nil}), do: nil

      def canonical_lexical(%__MODULE__{value: value, uncanonical_lexical: nil}),
        do: canonical_mapping(value)

      def canonical_lexical(%__MODULE__{} = literal),
        do: literal |> canonical() |> lexical()

      def canonical_lexical(_), do: nil

      @impl XSD.Datatype
      def init_valid_lexical(value, lexical, opts)
      def init_valid_lexical(_value, nil, _opts), do: nil
      def init_valid_lexical(_value, lexical, _opts), do: lexical

      @impl XSD.Datatype
      def init_invalid_lexical(value, _opts), do: to_string(value)

      @impl XSD.Datatype
      @spec canonical(t()) :: t()
      def canonical(literal)

      def canonical(%__MODULE__{uncanonical_lexical: nil} = literal), do: literal

      def canonical(%__MODULE__{value: @invalid_value} = literal), do: literal

      def canonical(%__MODULE__{} = literal),
        do: %__MODULE__{literal | uncanonical_lexical: nil}

      @impl XSD.Datatype
      @spec valid?(t() | any) :: boolean
      def valid?(literal)
      def valid?(%__MODULE__{value: @invalid_value}), do: false
      def valid?(%__MODULE__{}), do: true
      def valid?(_), do: false

      defp validate_cast(%__MODULE__{} = literal), do: if(valid?(literal), do: literal)
      defp validate_cast(_), do: nil

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

      @spec less_than?(t, t) :: boolean | nil
      def less_than?(literal1, literal2), do: XSD.Literal.less_than?(literal1, literal2)

      @spec greater_than?(t, t) :: boolean | nil
      def greater_than?(literal1, literal2), do: XSD.Literal.greater_than?(literal1, literal2)

      defoverridable canonical_mapping: 1,
                     init_valid_lexical: 3,
                     init_invalid_lexical: 2,
                     equal_value?: 2,
                     compare: 2
    end
  end
end
