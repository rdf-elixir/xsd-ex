defmodule XSD do
  @moduledoc """
  TODO: Documentation for XSD.
  """

  @datatypes [
    XSD.String,
    XSD.Integer,
    XSD.Double,
    XSD.Decimal,
    XSD.Boolean,
    XSD.Date,
    XSD.Time,
    XSD.DateTime
  ]

  def datatypes(), do: @datatypes

  @by_name Map.new(@datatypes, fn datatype -> {datatype.name(), datatype} end)

  def datatype_by_name(name), do: @by_name[name]

  @by_iri Map.new(@datatypes, fn datatype -> {datatype.id(), datatype} end)

  def datatype_by_iri(iri), do: @by_iri[iri]

  @doc """
  Returns if a given datatype is a XSD datatype.
  """
  # MapSet.member?(@datatypes, datatype)
  def datatype?(datatype), do: datatype in @datatypes

  @doc """
  Returns if a given value is a `XSD.datatype`.
  """
  def value?(%datatype{}), do: datatype?(datatype)
  def value?(_), do: false

  Enum.each(@datatypes, fn datatype ->
    defdelegate unquote(String.to_atom(datatype.name))(value), to: datatype, as: :new
    defdelegate unquote(String.to_atom(datatype.name))(value, opts), to: datatype, as: :new
  end)

  defdelegate datetime(value), to: XSD.DateTime, as: :new
  defdelegate datetime(value, opts), to: XSD.DateTime, as: :new

  defdelegate unquote(true)(), to: XSD.Boolean.Value
  defdelegate unquote(false)(), to: XSD.Boolean.Value
end
