defmodule XSD.ByteTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Byte,
    name: "byte",
    base: XSD.Short,
    base_primitive: XSD.Integer,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: -128,
      max_inclusive: 127
    },
    valid: XSD.TestData.valid_bytes(),
    invalid: XSD.TestData.invalid_bytes()
end
