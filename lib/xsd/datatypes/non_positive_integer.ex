defmodule XSD.NonPositiveInteger do
  use XSD.Datatype.Restriction,
    name: "nonPositiveInteger",
    base: XSD.Integer

  def_facet_constraint XSD.Facets.MaxInclusive, 0
end
