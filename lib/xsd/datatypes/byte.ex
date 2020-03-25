defmodule XSD.Byte do
  use XSD.Datatype.Restriction,
    name: "byte",
    base: XSD.Short

  def_facet_constraint XSD.Facets.MinInclusive, -128
  def_facet_constraint XSD.Facets.MaxInclusive, 127
end
