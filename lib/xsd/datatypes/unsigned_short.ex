defmodule XSD.UnsignedShort do
  use XSD.Datatype.Restriction,
    name: "unsigned_short",
    base: XSD.UnsignedInt

  def_facet_constraint XSD.Facets.MinInclusive, 0
  def_facet_constraint XSD.Facets.MaxInclusive, 65535
end
