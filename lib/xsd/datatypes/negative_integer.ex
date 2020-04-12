defmodule XSD.NegativeInteger do
  use XSD.Datatype.Restriction,
    name: "negativeInteger",
    base: XSD.NonPositiveInteger

  def_facet_constraint XSD.Facets.MaxInclusive, -1
end
