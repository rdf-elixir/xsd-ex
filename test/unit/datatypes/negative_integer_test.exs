defmodule XSD.NegativeIntegerTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.NegativeInteger,
    name: "negative_integer",
    base: XSD.NonPositiveInteger,
    base_primitive: XSD.Integer,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: nil,
      max_inclusive: -1
    },
    valid: XSD.TestData.valid_negative_integers(),
    invalid: XSD.TestData.invalid_negative_integers()
end
