defmodule XSD.Literal do
  @moduledoc """
  A generic interface to all `XSD.Datatype` struct implementations.
  """

  @type t :: %{
          :__struct__ => XSD.Datatype.t(),
          :value => any(),
          :uncanonical_lexical => XSD.Datatype.uncanonical_lexical()
        }

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
  def coerce(%URI{} = uri), do: XSD.AnyURI.new(uri)
  def coerce(%datatype{} = literal) when datatype in @datatypes, do: literal
  def coerce(_), do: nil

  @spec valid?(t() | any) :: boolean
  def valid?(literal)

  def valid?(%datatype{} = literal) when datatype in @datatypes,
    do: datatype.valid?(literal)

  def valid?(_), do: false

  @spec canonical(t()) :: t()
  def canonical(%datatype{} = literal) when datatype in @datatypes,
    do: datatype.canonical(literal)

  @spec lexical(t()) :: String.t()
  def lexical(%datatype{} = literal) when datatype in @datatypes,
    do: datatype.lexical(literal)

  @spec equal?(any, any) :: boolean
  def equal?(left, right), do: left == right

  @spec equal_value?(t | any, t | any) :: boolean
  def equal_value?(left, right)

  def equal_value?(%datatype{} = left, right) when datatype in @datatypes,
    do: datatype.equal_value?(left, right)

  def equal_value?(left, right) when not is_nil(left),
    do: equal_value?(coerce(left), right)

  def equal_value?(_, _), do: nil

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
  Matches the string representation of the given value against a XPath and XQuery regular expression pattern.

  The regular expression language is defined in _XQuery 1.0 and XPath 2.0 Functions and Operators_.

  see <https://www.w3.org/TR/xpath-functions/#func-matches>
  """
  @spec matches?(t(), pattern :: String.t(), flags :: String.t()) :: boolean
  def matches?(%datatype{} = literal, pattern, flags \\ "") do
    datatype.matches?(literal, pattern, flags)
  end
end
