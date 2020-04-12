defmodule XSD.NonPositiveIntegerTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.NonPositiveInteger,
    name: "nonPositiveInteger",
    base: XSD.Integer,
    base_primitive: XSD.Integer,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: nil,
      max_inclusive: 0
    },
    valid: XSD.TestData.valid_non_positive_integers(),
    invalid: XSD.TestData.invalid_non_positive_integers()
end
