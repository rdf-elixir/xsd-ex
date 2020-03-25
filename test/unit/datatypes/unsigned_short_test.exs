defmodule XSD.UnsignedShortTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.UnsignedShort,
    name: "unsigned_short",
    base: XSD.UnsignedInt,
    base_primitive: XSD.Integer,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: 0,
      max_inclusive: 65535
    },
    valid: XSD.TestData.valid_unsigned_shorts(),
    invalid: XSD.TestData.invalid_unsigned_shorts()
end
