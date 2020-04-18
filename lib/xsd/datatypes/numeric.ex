defmodule XSD.Numeric do
  alias Elixir.Decimal, as: D

  import Kernel, except: [abs: 1, floor: 1, ceil: 1]

  @datatypes MapSet.new([
               XSD.Decimal,
               XSD.Integer,
               XSD.Long,
               XSD.Int,
               XSD.Short,
               XSD.Byte,
               XSD.NonNegativeInteger,
               XSD.PositiveInteger,
               XSD.UnsignedLong,
               XSD.UnsignedInt,
               XSD.UnsignedShort,
               XSD.UnsignedByte,
               XSD.NonPositiveInteger,
               XSD.NegativeInteger,
               XSD.Double,
               XSD.Float
             ])

  @type t ::
          XSD.Decimal.t()
          | XSD.Integer.t()
          | XSD.Long.t()
          | XSD.Int.t()
          | XSD.Short.t()
          | XSD.Byte.t()
          | XSD.NonNegativeInteger.t()
          | XSD.PositiveInteger.t()
          | XSD.UnsignedLong.t()
          | XSD.UnsignedInt.t()
          | XSD.UnsignedShort.t()
          | XSD.UnsignedByte.t()
          | XSD.NonPositiveInteger.t()
          | XSD.NegativeInteger.t()
          | XSD.Double.t()
          | XSD.Float.t()

  @doc """
  The list of all numeric datatypes.
  """
  @spec datatypes() :: [XSD.Datatype.t()]
  def datatypes(), do: Enum.to_list(@datatypes)

  @doc """
  Returns if a given datatype is a numeric datatype.
  """
  @spec datatype?(XSD.Datatype.t() | any) :: boolean
  def datatype?(datatype), do: datatype in @datatypes

  @doc """
  Returns if a given XSD literal has a numeric datatype.
  """
  @spec literal?(XSD.Literal.t() | any) :: boolean
  def literal?(literal)
  def literal?(%datatype{}), do: datatype?(datatype)
  def literal?(_), do: false

  @doc """
  Tests for numeric value equality of two numeric XSD datatyped literals.

  see:

  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  - <https://www.w3.org/TR/xpath-functions/#func-numeric-equal>
  """
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
      do: not is_nil(left) and not is_nil(right) and equal_decimal_value?(left, right)

  def equal_value?(%left_datatype{value: left}, %right_datatype{value: right}) do
    if datatype?(left_datatype) and datatype?(right_datatype) do
      left != :nan and right != :nan and left == right
    end
  end

  def equal_value?(nil, _), do: nil
  def equal_value?(_, nil), do: nil

  def equal_value?(left, right),
    do: equal_value?(XSD.Literal.coerce(left), XSD.Literal.coerce(right))

  defp equal_decimal_value?(%D{} = left, %D{} = right), do: D.equal?(left, right)

  defp equal_decimal_value?(%D{} = left, right),
    do: equal_decimal_value?(left, new_decimal(right))

  defp equal_decimal_value?(left, %D{} = right),
    do: equal_decimal_value?(new_decimal(left), right)

  defp equal_decimal_value?(_, _), do: false

  defp new_decimal(value) when is_float(value), do: D.from_float(value)
  defp new_decimal(value), do: D.new(value)

  @doc """
  Compares two numeric XSD literals.

  Returns `:gt` if first literal is greater than the second and `:lt` for vice
  versa. If the two literals are equal `:eq` is returned.

  Returns `nil` when the given arguments are not comparable datatypes.

  """
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
  def negative_zero?(%{value: zero, uncanonical_lexical: "-" <> _}) when zero == 0, do: true
  def negative_zero?(%{value: %D{sign: -1, coef: 0}}), do: true
  def negative_zero?(_), do: false

  @doc """
  Adds two numeric literals.

  For `xsd:float` or `xsd:double` values, if one of the operands is a zero or a
  finite number and the other is INF or -INF, INF or -INF is returned. If both
  operands are INF, INF is returned. If both operands are -INF, -INF is returned.
  If one of the operands is INF and the other is -INF, NaN is returned.

  If one of the given arguments is not a numeric literal or a value which
  can be coerced into a numeric literal, `nil` is returned.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-add>

  """
  def add(arg1, arg2) do
    arithmetic_operation(:+, arg1, arg2, fn
      :positive_infinity, :negative_infinity, _ -> :nan
      :negative_infinity, :positive_infinity, _ -> :nan
      :positive_infinity, _, _ -> :positive_infinity
      _, :positive_infinity, _ -> :positive_infinity
      :negative_infinity, _, _ -> :negative_infinity
      _, :negative_infinity, _ -> :negative_infinity
      %D{} = arg1, %D{} = arg2, _ -> D.add(arg1, arg2)
      arg1, arg2, _ -> arg1 + arg2
    end)
  end

  @doc """
  Subtracts two numeric literals.

  For `xsd:float` or `xsd:double` values, if one of the operands is a zero or a
  finite number and the other is INF or -INF, an infinity of the appropriate sign
  is returned. If both operands are INF or -INF, NaN is returned. If one of the
  operands is INF and the other is -INF, an infinity of the appropriate sign is
  returned.

  If one of the given arguments is not a numeric literal or a value which
  can be coerced into a numeric literal, `nil` is returned.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-subtract>

  """
  def subtract(arg1, arg2) do
    arithmetic_operation(:-, arg1, arg2, fn
      :positive_infinity, :positive_infinity, _ -> :nan
      :negative_infinity, :negative_infinity, _ -> :nan
      :positive_infinity, :negative_infinity, _ -> :positive_infinity
      :negative_infinity, :positive_infinity, _ -> :negative_infinity
      :positive_infinity, _, _ -> :positive_infinity
      _, :positive_infinity, _ -> :negative_infinity
      :negative_infinity, _, _ -> :negative_infinity
      _, :negative_infinity, _ -> :positive_infinity
      %D{} = arg1, %D{} = arg2, _ -> D.sub(arg1, arg2)
      arg1, arg2, _ -> arg1 - arg2
    end)
  end

  @doc """
  Multiplies two numeric literals.

  For `xsd:float` or `xsd:double` values, if one of the operands is a zero and
  the other is an infinity, NaN is returned. If one of the operands is a non-zero
  number and the other is an infinity, an infinity with the appropriate sign is
  returned.

  If one of the given arguments is not a numeric literal or a value which
  can be coerced into a numeric literal, `nil` is returned.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-multiply>

  """
  def multiply(arg1, arg2) do
    arithmetic_operation(:*, arg1, arg2, fn
      :positive_infinity, :negative_infinity, _ -> :nan
      :negative_infinity, :positive_infinity, _ -> :nan
      inf, zero, _ when inf in [:positive_infinity, :negative_infinity] and zero == 0 -> :nan
      zero, inf, _ when inf in [:positive_infinity, :negative_infinity] and zero == 0 -> :nan
      :positive_infinity, number, _ when number < 0 -> :negative_infinity
      number, :positive_infinity, _ when number < 0 -> :negative_infinity
      :positive_infinity, _, _ -> :positive_infinity
      _, :positive_infinity, _ -> :positive_infinity
      :negative_infinity, number, _ when number < 0 -> :positive_infinity
      number, :negative_infinity, _ when number < 0 -> :positive_infinity
      :negative_infinity, _, _ -> :negative_infinity
      _, :negative_infinity, _ -> :negative_infinity
      %D{} = arg1, %D{} = arg2, _ -> D.mult(arg1, arg2)
      arg1, arg2, _ -> arg1 * arg2
    end)
  end

  @doc """
  Divides two numeric literals.

  For `xsd:float` and `xsd:double` operands, floating point division is performed
  as specified in [IEEE 754-2008]. A positive number divided by positive zero
  returns INF. A negative number divided by positive zero returns -INF. Division
  by negative zero returns -INF and INF, respectively. Positive or negative zero
  divided by positive or negative zero returns NaN. Also, INF or -INF divided by
  INF or -INF returns NaN.

  If one of the given arguments is not a numeric literal or a value which
  can be coerced into a numeric literal, `nil` is returned.

  `nil` is also returned for `xsd:decimal` and `xsd:integer` operands, if the
  divisor is (positive or negative) zero.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-divide>

  """
  def divide(arg1, arg2) do
    negative_zero = negative_zero?(arg2)

    arithmetic_operation(:/, arg1, arg2, fn
      inf1, inf2, _
      when inf1 in [:positive_infinity, :negative_infinity] and
             inf2 in [:positive_infinity, :negative_infinity] ->
        :nan

      %D{} = arg1, %D{coef: coef} = arg2, _ ->
        unless coef == 0, do: D.div(arg1, arg2)

      arg1, arg2, result_type ->
        if zero_value?(arg2) do
          cond do
            result_type not in [XSD.Double, XSD.Float] -> nil
            zero_value?(arg1) -> :nan
            negative_zero and arg1 < 0 -> :positive_infinity
            negative_zero -> :negative_infinity
            arg1 < 0 -> :negative_infinity
            true -> :positive_infinity
          end
        else
          arg1 / arg2
        end
    end)
  end

  @doc """
  Returns the absolute value of a numeric literal.

  If the given argument is not a numeric literal or a value which
  can be coerced into a numeric literal, `nil` is returned.

  see <http://www.w3.org/TR/xpath-functions/#func-abs>

  """
  def abs(literal)

  def abs(%XSD.Decimal{} = literal) do
    if XSD.Decimal.valid?(literal) do
      literal.value
      |> D.abs()
      |> XSD.Decimal.new()
    end
  end

  def abs(nil), do: nil

  def abs(value) do
    cond do
      literal?(value) ->
        if XSD.Literal.valid?(value) do
          %datatype{} = value

          case value.value do
            :nan ->
              value

            :positive_infinity ->
              value

            :negative_infinity ->
              datatype.new(:positive_infinity)

            value ->
              value
              |> Kernel.abs()
              |> datatype.new()
          end
        end

      XSD.literal?(value) ->
        nil

      true ->
        value
        |> XSD.Literal.coerce()
        |> abs()
    end
  end

  @doc """
  Rounds a value to a specified number of decimal places, rounding upwards if two such values are equally near.

  The function returns the nearest (that is, numerically closest) value to the
  given literal value that is a multiple of ten to the power of minus `precision`.
  If two such values are equally near (for example, if the fractional part in the
  literal value is exactly .5), the function returns the one that is closest to
  positive infinity.

  If the given argument is not a numeric literal or a value which
  can be coerced into a numeric literal, `nil` is returned.

  see <http://www.w3.org/TR/xpath-functions/#func-round>

  """
  def round(literal, precision \\ 0)

  def round(%XSD.Decimal{} = literal, precision) do
    if XSD.Decimal.valid?(literal) do
      literal.value
      |> xpath_round(precision)
      |> to_string()
      |> XSD.Decimal.new()
    end
  end

  def round(%datatype{value: value} = literal, _)
      when datatype in [XSD.Double, XSD.Float] and
             value in ~w[nan positive_infinity negative_infinity]a,
      do: literal

  def round(%datatype{} = literal, precision) when datatype in [XSD.Double, XSD.Float] do
    if datatype.valid?(literal) do
      literal.value
      |> new_decimal()
      |> xpath_round(precision)
      |> D.to_float()
      |> datatype.new()
    end
  end

  def round(nil, _), do: nil

  def round(value, precision) do
    cond do
      literal?(value) ->
        if XSD.Literal.valid?(value) do
          if precision < 0 do
            value.value
            |> new_decimal()
            |> xpath_round(precision)
            |> D.to_integer()
            |> XSD.Integer.new()
          else
            value
          end
        end

      XSD.literal?(value) ->
        nil

      true ->
        value
        |> XSD.Literal.coerce()
        |> round(precision)
    end
  end

  defp xpath_round(%D{sign: -1} = decimal, precision),
    do: D.round(decimal, precision, :half_down)

  defp xpath_round(decimal, precision),
    do: D.round(decimal, precision)

  @doc """
  Rounds a numeric literal upwards to a whole number literal.

  If the given argument is not a numeric literal or a value which
  can be coerced into a numeric literal, `nil` is returned.

  see <http://www.w3.org/TR/xpath-functions/#func-ceil>

  """
  def ceil(literal)

  def ceil(%XSD.Decimal{} = literal) do
    if XSD.Decimal.valid?(literal) do
      literal.value
      |> D.round(0, if(literal.value.sign == -1, do: :down, else: :up))
      |> D.to_string()
      |> XSD.Decimal.new()
    end
  end

  def ceil(%datatype{value: value} = literal)
      when datatype in [XSD.Double, XSD.Float] and
             value in ~w[nan positive_infinity negative_infinity]a,
      do: literal

  def ceil(%datatype{} = literal) when datatype in [XSD.Double, XSD.Float] do
    if datatype.valid?(literal) do
      literal.value
      |> Float.ceil()
      |> trunc()
      |> to_string()
      |> datatype.new()
    end
  end

  def ceil(nil), do: nil

  def ceil(value) do
    cond do
      literal?(value) ->
        if XSD.Literal.valid?(value) do
          value
        end

      XSD.literal?(value) ->
        nil

      true ->
        value
        |> XSD.Literal.coerce()
        |> ceil()
    end
  end

  @doc """
  Rounds a numeric literal downwards to a whole number literal.

  If the given argument is not a numeric literal or a value which
  can be coerced into a numeric literal, `nil` is returned.

  see <http://www.w3.org/TR/xpath-functions/#func-floor>

  """
  def floor(literal)

  def floor(%XSD.Decimal{} = literal) do
    if XSD.Decimal.valid?(literal) do
      literal.value
      |> D.round(0, if(literal.value.sign == -1, do: :up, else: :down))
      |> D.to_string()
      |> XSD.Decimal.new()
    end
  end

  def floor(%datatype{value: value} = literal)
      when datatype in [XSD.Double, XSD.Float] and
             value in ~w[nan positive_infinity negative_infinity]a,
      do: literal

  def floor(%datatype{} = literal) when datatype in [XSD.Double, XSD.Float] do
    if datatype.valid?(literal) do
      literal.value
      |> Float.floor()
      |> trunc()
      |> to_string()
      |> datatype.new()
    end
  end

  def floor(nil), do: nil

  def floor(value) do
    cond do
      literal?(value) ->
        if XSD.Literal.valid?(value) do
          value
        end

      XSD.literal?(value) ->
        nil

      true ->
        value
        |> XSD.Literal.coerce()
        |> floor()
    end
  end

  defp arithmetic_operation(op, %datatype1{} = literal1, %datatype2{} = literal2, fun) do
    if datatype?(datatype1) and datatype?(datatype2) do
      result_type = result_type(op, datatype1, datatype2)
      {arg1, arg2} = type_conversion(literal1, literal2, result_type)
      result = fun.(arg1.value, arg2.value, result_type)
      unless is_nil(result), do: result_type.new(result)
    end
  end

  defp arithmetic_operation(op, left, right, fun) do
    cond do
      is_nil(left) -> nil
      is_nil(right) -> nil
      not XSD.literal?(left) -> arithmetic_operation(op, XSD.Literal.coerce(left), right, fun)
      not XSD.literal?(right) -> arithmetic_operation(op, left, XSD.Literal.coerce(right), fun)
      true -> false
    end
  end

  defp type_conversion(%XSD.Decimal{} = left_decimal, %{value: right_value}, XSD.Decimal),
    do: {left_decimal, XSD.decimal(right_value)}

  defp type_conversion(%{value: left_value}, %XSD.Decimal{} = right_decimal, XSD.Decimal),
    do: {XSD.decimal(left_value), right_decimal}

  defp type_conversion(%XSD.Decimal{value: left_decimal}, right, datatype)
       when datatype in [XSD.Double, XSD.Float],
       do: {left_decimal |> D.to_float() |> XSD.double(), right}

  defp type_conversion(left, %XSD.Decimal{value: right_decimal}, datatype)
       when datatype in [XSD.Double, XSD.Float],
       do: {left, right_decimal |> D.to_float() |> XSD.double()}

  defp type_conversion(left, right, _), do: {left, right}

  defp result_type(_, XSD.Double, _), do: XSD.Double
  defp result_type(_, _, XSD.Double), do: XSD.Double
  defp result_type(_, XSD.Float, _), do: XSD.Float
  defp result_type(_, _, XSD.Float), do: XSD.Float
  defp result_type(_, XSD.Decimal, _), do: XSD.Decimal
  defp result_type(_, _, XSD.Decimal), do: XSD.Decimal
  defp result_type(:/, _, _), do: XSD.Decimal
  defp result_type(_, _, _), do: XSD.Integer
end
