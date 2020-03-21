defmodule XSD.NonNegativeInteger do
  use XSD.Datatype.Restriction,
    name: "non_negative_integer",
    base: XSD.Integer

  def_facet_constraint XSD.Facets.MinInclusive, 0
end
