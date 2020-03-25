defmodule XSD.UnsignedInt do
  use XSD.Datatype.Restriction,
    name: "unsigned_int",
    base: XSD.UnsignedLong

  def_facet_constraint XSD.Facets.MinInclusive, 0
  def_facet_constraint XSD.Facets.MaxInclusive, 4_294_967_295
end
