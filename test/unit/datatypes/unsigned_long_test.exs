defmodule XSD.UnsignedLongTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.UnsignedLong,
    name: "unsignedLong",
    base: XSD.NonNegativeInteger,
    base_primitive: XSD.Integer,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: 0,
      max_inclusive: 18_446_744_073_709_551_615
    },
    valid: XSD.TestData.valid_unsigned_longs(),
    invalid: XSD.TestData.invalid_unsigned_longs()
end
