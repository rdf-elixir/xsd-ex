defmodule XSD.Long do
  use XSD.Datatype.Restriction,
    name: "long",
    base: XSD.Integer

  def_facet_constraint XSD.Facets.MinInclusive, -9_223_372_036_854_775_808
  def_facet_constraint XSD.Facets.MaxInclusive, 9_223_372_036_854_775_807
end
