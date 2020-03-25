defmodule XSD.LongTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Long,
    name: "long",
    base: XSD.Integer,
    base_primitive: XSD.Integer,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: -9_223_372_036_854_775_808,
      max_inclusive: 9_223_372_036_854_775_807
    },
    valid: XSD.TestData.valid_longs(),
    invalid: XSD.TestData.invalid_longs()
end
