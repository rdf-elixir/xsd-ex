defmodule XSD.ShortTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Short,
    name: "short",
    base: XSD.Int,
    base_primitive: XSD.Integer,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: -32768,
      max_inclusive: 32767
    },
    valid: XSD.TestData.valid_shorts(),
    invalid: XSD.TestData.invalid_shorts()
end
