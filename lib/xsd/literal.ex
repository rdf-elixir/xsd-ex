defmodule XSD.Literal do
  @type t ::
          XSD.Boolean.t()
          | XSD.Integer.t()
          | XSD.NonNegativeInteger.t()
          | XSD.PositiveInteger.t()
          | XSD.Double.t()
          | XSD.String.t()
          | XSD.Decimal.t()
          | XSD.Date.t()
          | XSD.Time.t()
          | XSD.DateTime.t()

  @datatypes XSD.datatypes()

  @spec base_primitive(t()) :: XSD.Datatype.t()
  def base_primitive(%datatype{}),
    do: XSD.Datatype.base_primitive(datatype)

  @spec derived_from?(t(), XSD.Datatype.t()) :: boolean
  def derived_from?(%datatype{}, super_datatype),
    do: XSD.Datatype.derived_from?(datatype, super_datatype)

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
  """
  @spec less_than?(t, t) :: boolean
  def less_than?(left, right) do
    compare(left, right) == :lt
  end

  @doc """
  Checks if the first of two `XSD.Datatype` literals is greater then the other.
  """
  @spec greater_than?(t, t) :: boolean
  def greater_than?(left, right) do
    compare(left, right) == :gt
  end

  @doc """
  Checks if two `XSD.Literal`s are comparable with respect to their types or because one of them is invalid.
  """
  @spec comparable?(t(), t() | XSD.Datatype.t()) :: boolean
  def comparable?(left, right)

  def comparable?(%_datatype{value: nil}, _), do: false
  def comparable?(_, %_datatype{value: nil}), do: false

  def comparable?(%datatype1{}, %datatype2{}), do: XSD.Datatype.comparable?(datatype1, datatype2)

  def comparable?(%datatype1{}, datatype2) when is_atom(datatype2),
    do: XSD.Datatype.comparable?(datatype1, datatype2)

  def comparable?(_, _), do: false
end
