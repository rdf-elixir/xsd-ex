defmodule XSD.IntTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Int,
    name: "int",
    base: XSD.Long,
    base_primitive: XSD.Integer,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: -2_147_483_648,
      max_inclusive: 2_147_483_647
    },
    valid: XSD.TestData.valid_ints(),
    invalid: XSD.TestData.invalid_ints()
end
