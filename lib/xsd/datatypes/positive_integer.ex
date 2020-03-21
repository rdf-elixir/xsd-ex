defmodule XSD.PositiveInteger do
  use XSD.Datatype.Restriction,
    name: "positive_integer",
    base: XSD.NonNegativeInteger

  def_facet_constraint XSD.Facets.MinInclusive, 1
end
