defmodule XSD.Numeric do
  alias Elixir.Decimal, as: D

  import Kernel, except: [abs: 1, floor: 1, ceil: 1]

  @datatypes MapSet.new([
               XSD.Decimal,
               XSD.Integer,
               XSD.Double
             ])

  @type t :: XSD.Decimal.t() | XSD.Integer.t() | XSD.Double.t()

  @doc """
  The list of all numeric datatypes.
  """
  @spec datatypes() :: [XSD.Datatype.t()]
  # https://elixirforum.com/t/dialyzer-complaint-about-mapset-member-not-getting-proper-type-as-argument-possible-specs-bug-in-mapset/20780
  @dialyzer {:nowarn_function, datatypes: 0}
  def datatypes(), do: MapSet.to_list(@datatypes)

  @doc """
  Returns if a given datatype is a numeric datatype.
  """
  @spec datatype?(XSD.Datatype.t() | any) :: boolean
  # https://elixirforum.com/t/dialyzer-complaint-about-mapset-member-not-getting-proper-type-as-argument-possible-specs-bug-in-mapset/20780
  @dialyzer {:nowarn_function, datatype?: 1}
  def datatype?(datatype), do: MapSet.member?(@datatypes, datatype)

  @doc """
  Returns if a given XSD literal has a numeric datatype.
  """
  @spec literal?(XSD.Literal.t() | any) :: boolean
  def literal?(literal)
  def literal?(%datatype{}), do: datatype?(datatype)
  def literal?(_), do: false

  @spec equal_value?(t() | any, t() | any) :: boolean
  def equal_value?(left, right)

  def equal_value?(
        %datatype{value: nil, uncanonical_lexical: lexical1},
        %datatype{value: nil, uncanonical_lexical: lexical2}
      ) do
    lexical1 == lexical2
  end

  def equal_value?(%left_datatype{value: left}, %right_datatype{value: right})
      when left_datatype == XSD.Decimal or right_datatype == XSD.Decimal,
      do: equal_decimal_value?(left, right)

  def equal_value?(%left_datatype{value: left}, %right_datatype{value: right}) do
    XSD.datatype?(left_datatype) and
      XSD.datatype?(right_datatype) and
      left != :nan and
      right != :nan and
      left == right
  end

  def equal_value?(_, _), do: false

  defp equal_decimal_value?(%D{} = left, %D{} = right), do: D.equal?(left, right)

  defp equal_decimal_value?(%D{} = left, right),
    do: equal_decimal_value?(left, new_decimal(right))

  defp equal_decimal_value?(left, %D{} = right),
    do: equal_decimal_value?(new_decimal(left), right)

  defp equal_decimal_value?(_, _), do: false

  defp new_decimal(value) when is_float(value), do: D.from_float(value)
  defp new_decimal(value), do: D.new(value)

  @spec compare(t, t) :: XSD.Datatype.comparison_result() | nil
  def compare(left, right)

  def compare(
        %XSD.Decimal{value: left},
        %right_datatype{value: right}
      ) do
    if datatype?(right_datatype) do
      compare_decimal_value(left, right)
    end
  end

  def compare(
        %left_datatype{value: left},
        %XSD.Decimal{value: right}
      ) do
    if datatype?(left_datatype) do
      compare_decimal_value(left, right)
    end
  end

  def compare(
        %left_datatype{value: left},
        %right_datatype{value: right}
      )
      when not (is_nil(left) or is_nil(right)) do
    if datatype?(left_datatype) and datatype?(right_datatype) do
      cond do
        left < right -> :lt
        left > right -> :gt
        true -> :eq
      end
    end
  end

  def compare(_, _), do: nil

  # probably caused by the ignored opaque MapSet.t type issue above
  @dialyzer {:nowarn_function, compare_decimal_value: 2}
  defp compare_decimal_value(%D{} = left, %D{} = right), do: D.cmp(left, right)

  defp compare_decimal_value(%D{} = left, right),
    do: compare_decimal_value(left, new_decimal(right))

  defp compare_decimal_value(left, %D{} = right),
    do: compare_decimal_value(new_decimal(left), right)

  defp compare_decimal_value(_, _), do: nil

  @spec zero?(any) :: boolean
  def zero?(%{value: value}), do: zero_value?(value)
  defp zero_value?(zero) when zero == 0, do: true
  defp zero_value?(%D{coef: 0}), do: true
  defp zero_value?(_), do: false

  @spec negative_zero?(any) :: boolean
  def negative_zero?(%XSD.Double{value: zero, uncanonical_lexical: "-" <> _}) when zero == 0,
    do: true

  def negative_zero?(%{value: %D{sign: -1, coef: 0}}), do: true
  def negative_zero?(_), do: false
end
