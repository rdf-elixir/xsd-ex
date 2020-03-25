defmodule XSD.NonPositiveInteger do
  use XSD.Datatype.Restriction,
    name: "non_positive_integer",
    base: XSD.Integer

  def_facet_constraint XSD.Facets.MaxInclusive, 0
end
