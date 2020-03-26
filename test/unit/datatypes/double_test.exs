defmodule XSD.DoubleTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Double,
    name: "double",
    primitive: true,
    comparable_datatypes: [XSD.Integer, XSD.Decimal],
    valid: XSD.TestData.valid_floats(),
    invalid: XSD.TestData.invalid_floats()

  describe "cast/1" do
    test "casting a double returns the input as it is" do
      assert XSD.double(3.14) |> XSD.Double.cast() == XSD.double(3.14)
      assert XSD.double("NAN") |> XSD.Double.cast() == XSD.double("NAN")
      assert XSD.double("-INF") |> XSD.Double.cast() == XSD.double("-INF")
    end

    test "casting a boolean" do
      assert XSD.true() |> XSD.Double.cast() == XSD.double(1.0)
      assert XSD.false() |> XSD.Double.cast() == XSD.double(0.0)
    end

    test "casting a string with a value from the lexical value space of xsd:double" do
      assert XSD.string("1.0") |> XSD.Double.cast() == XSD.double("1.0E0")
      assert XSD.string("3.14") |> XSD.Double.cast() == XSD.double("3.14E0")
      assert XSD.string("3.14E0") |> XSD.Double.cast() == XSD.double("3.14E0")
    end

    test "casting a string with a value not in the lexical value space of xsd:double" do
      assert XSD.string("foo") |> XSD.Double.cast() == nil
    end

    test "casting an integer" do
      assert XSD.integer(0) |> XSD.Double.cast() == XSD.double(0.0)
      assert XSD.integer(42) |> XSD.Double.cast() == XSD.double(42.0)
    end

    test "casting a decimal" do
      assert XSD.decimal(0) |> XSD.Double.cast() == XSD.double(0)
      assert XSD.decimal(1) |> XSD.Double.cast() == XSD.double(1)
      assert XSD.decimal(3.14) |> XSD.Double.cast() == XSD.double(3.14)
    end

    test "casting a float" do
      assert XSD.float(0) |> XSD.Double.cast() == XSD.double(0)
      assert XSD.float(1) |> XSD.Double.cast() == XSD.double(1)
      assert XSD.float(3.14) |> XSD.Double.cast() == XSD.double(3.14)
    end

    test "with invalid literals" do
      assert XSD.boolean("42") |> XSD.Double.cast() == nil
      assert XSD.integer(3.14) |> XSD.Double.cast() == nil
      assert XSD.decimal("NAN") |> XSD.Double.cast() == nil
      assert XSD.double(true) |> XSD.Double.cast() == nil
    end

    test "with literals of unsupported datatypes" do
      assert XSD.date("2020-01-01") |> XSD.Double.cast() == nil
    end

    test "with coercible value" do
      assert XSD.Double.cast("3.14") == XSD.double(3.14) |> XSD.Double.canonical()
    end

    test "with non-coercible value" do
      assert XSD.Double.cast(:foo) == nil
      assert XSD.Double.cast(make_ref()) == nil
    end
  end
end
