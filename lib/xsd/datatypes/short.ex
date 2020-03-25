defmodule XSD.Short do
  use XSD.Datatype.Restriction,
    name: "short",
    base: XSD.Int

  def_facet_constraint XSD.Facets.MinInclusive, -32768
  def_facet_constraint XSD.Facets.MaxInclusive, 32767
end
