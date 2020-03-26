defmodule XSD.FloatTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Float,
    name: "float",
    base: XSD.Double,
    base_primitive: XSD.Double,
    comparable_datatypes: [XSD.Integer, XSD.Decimal],
    applicable_facets: [],
    facets: %{},
    valid: XSD.TestData.valid_floats(),
    invalid: XSD.TestData.invalid_floats()
end
