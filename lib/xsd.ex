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

  defdelegate unquote(true)(), to: XSD.Boolean.Value
  defdelegate unquote(false)(), to: XSD.Boolean.Value
end
