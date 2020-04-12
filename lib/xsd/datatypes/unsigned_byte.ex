defmodule XSD.UnsignedByte do
  use XSD.Datatype.Restriction,
    name: "unsignedByte",
    base: XSD.UnsignedShort

  def_facet_constraint XSD.Facets.MinInclusive, 0
  def_facet_constraint XSD.Facets.MaxInclusive, 255
end
