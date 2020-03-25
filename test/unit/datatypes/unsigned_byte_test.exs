defmodule XSD.UnsignedByteTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.UnsignedByte,
    name: "unsigned_byte",
    base: XSD.UnsignedShort,
    base_primitive: XSD.Integer,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: 0,
      max_inclusive: 255
    },
    valid: XSD.TestData.valid_unsigned_bytes(),
    invalid: XSD.TestData.invalid_unsigned_bytes()
end
