defmodule XSD.Int do
  use XSD.Datatype.Restriction,
    name: "int",
    base: XSD.Long

  def_facet_constraint XSD.Facets.MinInclusive, -2_147_483_648
  def_facet_constraint XSD.Facets.MaxInclusive, 2_147_483_647
end
