defmodule XSD.Literal do
  @type t ::
          XSD.Boolean.t()
          | XSD.Integer.t()
          | XSD.Double.t()
          | XSD.String.t()
          | XSD.Decimal.t()
          | XSD.Date.t()
          | XSD.Time.t()
          | XSD.DateTime.t()

  @datatypes XSD.datatypes()

  @spec coerce(any) :: t() | nil
  def coerce(value)
  def coerce(boolean) when is_boolean(boolean), do: XSD.Boolean.new(boolean)
  def coerce(string) when is_binary(string), do: XSD.String.new(string)
  def coerce(integer) when is_integer(integer), do: XSD.Integer.new(integer)
  def coerce(float) when is_float(float), do: XSD.Double.new(float)
  def coerce(%Decimal{} = decimal), do: XSD.Decimal.new(decimal)
  def coerce(%DateTime{} = datetime), do: XSD.DateTime.new(datetime)
  def coerce(%NaiveDateTime{} = datetime), do: XSD.DateTime.new(datetime)
  def coerce(%Date{} = date), do: XSD.Date.new(date)
  def coerce(%Time{} = time), do: XSD.Time.new(time)
  def coerce(_), do: nil

  @spec equal?(any, any) :: boolean
  def equal?(left, right), do: left == right

  @spec equal_value?(t, t) :: boolean
  def equal_value?(left, right)

  def equal_value?(%datatype{} = left, right) when datatype in @datatypes,
    do: datatype.equal_value?(left, right)

  def equal_value?(_, _), do: false

  @spec compare(t, t) :: XSD.Datatype.comparison_result() | :indeterminate | nil
  def compare(left, right)

  def compare(%datatype{} = left, right) when datatype in @datatypes,
    do: datatype.compare(left, right)

  def compare(_, _), do: nil

  @doc """
  Checks if the first of two `XSD.Datatype` literals is smaller then the other.

  Returns `nil` when the given arguments are not comparable datatypes.
  """
  @spec less_than?(t, t) :: boolean | nil
  def less_than?(left, right) do
    case compare(left, right) do
      :lt -> true
      nil -> nil
      _ -> false
    end
  end

  @doc """
  Checks if the first of two `XSD.Datatype` literals is greater then the other.

  Returns `nil` when the given arguments are not comparable datatypes.
  """
  @spec greater_than?(t, t) :: boolean | nil
  def greater_than?(left, right) do
    case compare(left, right) do
      :gt -> true
      nil -> nil
      _ -> false
    end
  end
end
