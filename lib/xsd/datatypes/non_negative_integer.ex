defmodule XSD.NonNegativeInteger do
  use XSD.Datatype.Restriction,
    name: "nonNegativeInteger",
    base: XSD.Integer

  def_facet_constraint XSD.Facets.MinInclusive, 0
end
