defmodule XSD.UnsignedIntTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.UnsignedInt,
    name: "unsigned_int",
    base: XSD.UnsignedLong,
    base_primitive: XSD.Integer,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: 0,
      max_inclusive: 4_294_967_295
    },
    valid: XSD.TestData.valid_unsigned_ints(),
    invalid: XSD.TestData.invalid_unsigned_ints()
end
