defmodule XSD.UnsignedLong do
  use XSD.Datatype.Restriction,
    name: "unsignedLong",
    base: XSD.NonNegativeInteger

  def_facet_constraint XSD.Facets.MinInclusive, 0
  def_facet_constraint XSD.Facets.MaxInclusive, 18_446_744_073_709_551_615
end
