defmodule XSD.PositiveIntegerTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.PositiveInteger,
    name: "positive_integer",
    base: XSD.NonNegativeInteger,
    base_primitive: XSD.Integer,
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: 1,
      max_inclusive: nil
    },
    valid: XSD.TestData.valid_positive_integer(),
    invalid: XSD.TestData.invalid_positive_integer()

  describe "cast/1" do
    test "casting a positive_integer returns the input as it is" do
      assert XSD.positive_integer(1) |> XSD.PositiveInteger.cast() ==
               XSD.positive_integer(1)

      assert XSD.positive_integer(1) |> XSD.PositiveInteger.cast() ==
               XSD.positive_integer(1)
    end

    test "casting an integer with a value from the value space of positive_integer" do
      assert XSD.integer(1) |> XSD.PositiveInteger.cast() ==
               XSD.positive_integer(1)
    end

    test "casting an integer with a value not from the value space of positive_integer" do
      assert XSD.integer(-1) |> XSD.PositiveInteger.cast() == nil
      assert XSD.non_negative_integer(0) |> XSD.PositiveInteger.cast() == nil
    end

    test "casting a positive_integer" do
      assert XSD.positive_integer(1) |> XSD.PositiveInteger.cast() ==
               XSD.positive_integer(1)
    end

    test "casting a boolean" do
      assert XSD.true() |> XSD.PositiveInteger.cast() == XSD.positive_integer(1)
    end

    test "casting a string with a value from the lexical value space of xsd:integer" do
      assert XSD.string("1") |> XSD.PositiveInteger.cast() == XSD.positive_integer(1)
      assert XSD.string("042") |> XSD.PositiveInteger.cast() == XSD.positive_integer(42)
      assert XSD.string("0") |> XSD.PositiveInteger.cast() == nil
    end

    test "casting a string with a value not in the lexical value space of xsd:integer" do
      assert XSD.string("foo") |> XSD.PositiveInteger.cast() == nil
      assert XSD.string("3.14") |> XSD.PositiveInteger.cast() == nil
    end

    test "casting an decimal" do
      assert XSD.decimal(1.0) |> XSD.PositiveInteger.cast() == XSD.positive_integer(1)
      assert XSD.decimal(3.14) |> XSD.PositiveInteger.cast() == XSD.positive_integer(3)
      assert XSD.decimal(0) |> XSD.PositiveInteger.cast() == nil
    end

    test "casting a double" do
      assert XSD.double(1) |> XSD.PositiveInteger.cast() == XSD.positive_integer(1)
      assert XSD.double(1.0) |> XSD.PositiveInteger.cast() == XSD.positive_integer(1)
      assert XSD.double(1.1) |> XSD.PositiveInteger.cast() == XSD.positive_integer(1)
      assert XSD.double("+1") |> XSD.PositiveInteger.cast() == XSD.positive_integer(1)
      assert XSD.double("+1.0") |> XSD.PositiveInteger.cast() == XSD.positive_integer(1)
      assert XSD.double("1.0E0") |> XSD.PositiveInteger.cast() == XSD.positive_integer(1)
      assert XSD.double(3.14) |> XSD.PositiveInteger.cast() == XSD.positive_integer(3)

      assert XSD.double("NAN") |> XSD.PositiveInteger.cast() == nil
      assert XSD.double("+INF") |> XSD.PositiveInteger.cast() == nil
      assert XSD.double(0) |> XSD.PositiveInteger.cast() == nil
      assert XSD.double(0.0) |> XSD.PositiveInteger.cast() == nil
      assert XSD.double(0.1) |> XSD.PositiveInteger.cast() == nil
      assert XSD.double("+0") |> XSD.PositiveInteger.cast() == nil
      assert XSD.double("+0.0") |> XSD.PositiveInteger.cast() == nil
      assert XSD.double("-0.0") |> XSD.PositiveInteger.cast() == nil
      assert XSD.double("0.0E0") |> XSD.PositiveInteger.cast() == nil
      assert XSD.double("-1.0") |> XSD.PositiveInteger.cast() == nil
    end

    @tag skip: "TODO: XSD.Float datatype"
    test "casting a float"

    test "with invalid literals" do
      assert XSD.positive_integer(3.14) |> XSD.PositiveInteger.cast() == nil
      assert XSD.positive_integer(0) |> XSD.PositiveInteger.cast() == nil
      assert XSD.decimal("NAN") |> XSD.PositiveInteger.cast() == nil
      assert XSD.double(true) |> XSD.PositiveInteger.cast() == nil
    end

    test "with literals of unsupported datatypes" do
      assert XSD.date("2020-01-01") |> XSD.PositiveInteger.cast() == nil
    end

    test "with coercible value" do
      assert XSD.PositiveInteger.cast("42") == XSD.positive_integer(42)
      assert XSD.PositiveInteger.cast(3.14) == XSD.positive_integer(3)
      assert XSD.PositiveInteger.cast(true) == XSD.positive_integer(1)
      assert XSD.PositiveInteger.cast(false) == nil
    end

    test "with non-coercible value" do
      assert XSD.PositiveInteger.cast(:foo) == nil
      assert XSD.PositiveInteger.cast(make_ref()) == nil
    end
  end
end
