defmodule XSD.IntegerTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Integer,
    name: "integer",
    primitive: true,
    comparable_datatypes: [XSD.Decimal, XSD.Double],
    applicable_facets: [XSD.Facets.MinInclusive, XSD.Facets.MaxInclusive],
    facets: %{
      min_inclusive: nil,
      max_inclusive: nil
    },
    valid: XSD.TestData.valid_integers(),
    invalid: XSD.TestData.invalid_integers()

  describe "cast/1" do
    test "casting an integer returns the input as it is" do
      assert XSD.integer(0) |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.integer(1) |> XSD.Integer.cast() == XSD.integer(1)
    end

    test "casting a boolean" do
      assert XSD.false() |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.true() |> XSD.Integer.cast() == XSD.integer(1)
    end

    test "casting a string with a value from the lexical value space of xsd:integer" do
      assert XSD.string("0") |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.string("042") |> XSD.Integer.cast() == XSD.integer(42)
    end

    test "casting a string with a value not in the lexical value space of xsd:integer" do
      assert XSD.string("foo") |> XSD.Integer.cast() == nil
      assert XSD.string("3.14") |> XSD.Integer.cast() == nil
    end

    test "casting an decimal" do
      assert XSD.decimal(0) |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.decimal(1.0) |> XSD.Integer.cast() == XSD.integer(1)
      assert XSD.decimal(3.14) |> XSD.Integer.cast() == XSD.integer(3)
    end

    test "casting a double" do
      assert XSD.double(0) |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.double(0.0) |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.double(0.1) |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.double("+0") |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.double("+0.0") |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.double("-0.0") |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.double("0.0E0") |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.double(1) |> XSD.Integer.cast() == XSD.integer(1)
      assert XSD.double(3.14) |> XSD.Integer.cast() == XSD.integer(3)

      assert XSD.double("NAN") |> XSD.Integer.cast() == nil
      assert XSD.double("+INF") |> XSD.Integer.cast() == nil
    end

    test "casting a float" do
      assert XSD.float(0) |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.float(0.0) |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.float(0.1) |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.float("+0") |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.float("+0.0") |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.float("-0.0") |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.float("0.0E0") |> XSD.Integer.cast() == XSD.integer(0)
      assert XSD.float(1) |> XSD.Integer.cast() == XSD.integer(1)
      assert XSD.float(3.14) |> XSD.Integer.cast() == XSD.integer(3)

      assert XSD.float("NAN") |> XSD.Integer.cast() == nil
      assert XSD.float("+INF") |> XSD.Integer.cast() == nil
    end

    test "with invalid literals" do
      assert XSD.integer(3.14) |> XSD.Integer.cast() == nil
      assert XSD.decimal("NAN") |> XSD.Integer.cast() == nil
      assert XSD.double(true) |> XSD.Integer.cast() == nil
    end

    test "with literals of unsupported datatypes" do
      assert XSD.date("2020-01-01") |> XSD.Integer.cast() == nil
    end

    test "with coercible value" do
      assert XSD.Integer.cast("42") == XSD.integer(42)
      assert XSD.Integer.cast(3.14) == XSD.integer(3)
      assert XSD.Integer.cast(true) == XSD.integer(1)
      assert XSD.Integer.cast(false) == XSD.integer(0)
    end

    test "with non-coercible value" do
      assert XSD.Integer.cast(:foo) == nil
      assert XSD.Integer.cast(make_ref()) == nil
    end
  end

  #  test "digit_count/1" do
  #    assert XSD.Integer.digit_count(XSD.integer("2")) == 1
  #    assert XSD.Integer.digit_count(XSD.integer("23")) == 2
  #    assert XSD.Integer.digit_count(XSD.integer("023")) == 2
  #    assert XSD.Integer.digit_count(XSD.integer("+023")) == 2
  #    assert XSD.Integer.digit_count(XSD.integer("-023")) == 2
  #    assert XSD.Integer.digit_count(XSD.integer("NaN")) == nil
  #  end
end
