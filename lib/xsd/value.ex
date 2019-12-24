defmodule XSD.Value do
  @datatypes XSD.datatypes()

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

  def equal?(left, right), do: left == right

  def equal_value?(left, right)

  def equal_value?(%datatype{} = left, right) when datatype in @datatypes,
    do: datatype.equal_value?(left, right)

  def equal_value?(_, _), do: false
end
