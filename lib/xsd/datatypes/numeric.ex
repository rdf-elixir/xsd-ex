defmodule XSD.Numeric do
  alias Elixir.Decimal, as: D

  import Kernel, except: [abs: 1, floor: 1, ceil: 1]

  @datatypes MapSet.new([
               XSD.Decimal,
               XSD.Integer,
               XSD.Double
             ])

  @doc """
  The list of all numeric datatypes.
  """
  def datatypes(), do: MapSet.to_list(@datatypes)

  @doc """
  Returns if a given datatype is a numeric datatype.
  """
  def datatype?(datatype), do: MapSet.member?(@datatypes, datatype)

  @doc """
  Returns if a given XSD value has a numeric datatype.
  """
  def value?(%datatype{}), do: datatype?(datatype)
  def value?(_), do: false

  def zero?(%{value: value}), do: zero_value?(value)
  defp zero_value?(zero) when zero == 0, do: true
  defp zero_value?(%D{coef: 0}), do: true
  defp zero_value?(_), do: false

  def negative_zero?(%XSD.Double{value: zero, uncanonical_lexical: "-" <> _}) when zero == 0,
    do: true

  def negative_zero?(%{value: %D{sign: -1, coef: 0}}), do: true
  def negative_zero?(_), do: false
end
