defmodule XSD.NonNegativeIntegerTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.NonNegativeInteger,
    name: "non_negative_integer",
    base: XSD.Integer,
    base_primitive: XSD.Integer,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: 0,
      max_inclusive: nil
    },
    valid: XSD.TestData.valid_non_negative_integers(),
    invalid: XSD.TestData.invalid_non_negative_integers()

  describe "cast/1" do
    test "casting a non_negative_integer returns the input as it is" do
      assert XSD.non_negative_integer(0) |> XSD.NonNegativeInteger.cast() ==
               XSD.non_negative_integer(0)

      assert XSD.non_negative_integer(1) |> XSD.NonNegativeInteger.cast() ==
               XSD.non_negative_integer(1)
    end

    test "casting an integer with a value from the value space of non_negative_integer" do
      assert XSD.integer(0) |> XSD.NonNegativeInteger.cast() ==
               XSD.non_negative_integer(0)

      assert XSD.integer(1) |> XSD.NonNegativeInteger.cast() ==
               XSD.non_negative_integer(1)
    end

    test "casting an integer with a value not from the value space of non_negative_integer" do
      assert XSD.integer(-1) |> XSD.NonNegativeInteger.cast() == nil
    end

    test "casting a positive_integer" do
      assert XSD.positive_integer(1) |> XSD.NonNegativeInteger.cast() ==
               XSD.non_negative_integer(1)
    end

    test "casting a boolean" do
      assert XSD.false() |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(0)
      assert XSD.true() |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(1)
    end

    test "casting a string with a value from the lexical value space of xsd:integer" do
      assert XSD.string("0") |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(0)
      assert XSD.string("042") |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(42)
    end

    test "casting a string with a value not in the lexical value space of xsd:integer" do
      assert XSD.string("foo") |> XSD.NonNegativeInteger.cast() == nil
      assert XSD.string("3.14") |> XSD.NonNegativeInteger.cast() == nil
    end

    test "casting an decimal" do
      assert XSD.decimal(0) |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(0)
      assert XSD.decimal(1.0) |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(1)
      assert XSD.decimal(3.14) |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(3)
    end

    test "casting a double" do
      assert XSD.double(0) |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(0)
      assert XSD.double(0.0) |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(0)
      assert XSD.double(0.1) |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(0)
      assert XSD.double("+0") |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(0)
      assert XSD.double("+0.0") |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(0)
      assert XSD.double("-0.0") |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(0)
      assert XSD.double("0.0E0") |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(0)
      assert XSD.double(1) |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(1)
      assert XSD.double(3.14) |> XSD.NonNegativeInteger.cast() == XSD.non_negative_integer(3)

      assert XSD.double("NAN") |> XSD.NonNegativeInteger.cast() == nil
      assert XSD.double("+INF") |> XSD.NonNegativeInteger.cast() == nil
    end

    @tag skip: "TODO: XSD.Float datatype"
    test "casting a float"

    test "with invalid literals" do
      assert XSD.non_negative_integer(3.14) |> XSD.NonNegativeInteger.cast() == nil
      assert XSD.positive_integer(0) |> XSD.NonNegativeInteger.cast() == nil
      assert XSD.decimal("NAN") |> XSD.NonNegativeInteger.cast() == nil
      assert XSD.double(true) |> XSD.NonNegativeInteger.cast() == nil
    end

    test "with literals of unsupported datatypes" do
      assert XSD.date("2020-01-01") |> XSD.NonNegativeInteger.cast() == nil
    end

    test "with coercible value" do
      assert XSD.NonNegativeInteger.cast("42") == XSD.non_negative_integer(42)
      assert XSD.NonNegativeInteger.cast(3.14) == XSD.non_negative_integer(3)
      assert XSD.NonNegativeInteger.cast(true) == XSD.non_negative_integer(1)
      assert XSD.NonNegativeInteger.cast(false) == XSD.non_negative_integer(0)
    end

    test "with non-coercible value" do
      assert XSD.NonNegativeInteger.cast(:foo) == nil
      assert XSD.NonNegativeInteger.cast(make_ref()) == nil
    end
  end
end
