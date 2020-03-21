defmodule XSD.DoubleTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Double,
    name: "double",
    primitive: true,
    valid: %{
      # input => { value, lexical, canonicalized }
      0 => {0.0, "0.0", "0.0E0"},
      42 => {42.0, "42.0", "4.2E1"},
      0.0e0 => {0.0, "0.0", "0.0E0"},
      1.0e0 => {1.0, "1.0", "1.0E0"},
      :positive_infinity => {:positive_infinity, nil, "INF"},
      :negative_infinity => {:negative_infinity, nil, "-INF"},
      :nan => {:nan, nil, "NaN"},
      "1.0E0" => {1.0e0, nil, "1.0E0"},
      "0.0" => {0.0, "0.0", "0.0E0"},
      "1" => {1.0e0, "1", "1.0E0"},
      "01" => {1.0e0, "01", "1.0E0"},
      "0123" => {1.23e2, "0123", "1.23E2"},
      "-1" => {-1.0e0, "-1", "-1.0E0"},
      "+01.000" => {1.0e0, "+01.000", "1.0E0"},
      "1.0" => {1.0e0, "1.0", "1.0E0"},
      "123.456" => {1.23456e2, "123.456", "1.23456E2"},
      "1.0e+1" => {1.0e1, "1.0e+1", "1.0E1"},
      "1.0e-10" => {1.0e-10, "1.0e-10", "1.0E-10"},
      "123.456e4" => {1.23456e6, "123.456e4", "1.23456E6"},
      "1.E-8" => {1.0e-8, "1.E-8", "1.0E-8"},
      "3E1" => {3.0e1, "3E1", "3.0E1"},
      "INF" => {:positive_infinity, nil, "INF"},
      "Inf" => {:positive_infinity, "Inf", "INF"},
      "-INF" => {:negative_infinity, nil, "-INF"},
      "NaN" => {:nan, nil, "NaN"}
    },
    invalid: ["foo", "12.xyz", "1.0ez", "+INF", true, false, "1.1e1 foo", "foo 1.1e1"]

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

    @tag skip: "TODO: XSD.Float datatype"
    test "casting a float"

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

  describe "Elixir equality" do
    test "two literals are equal when they have the same datatype and lexical form" do
      [
        {"1.0", 1.0},
        {"-42.0", -42.0},
        {"1.0", 1.0}
      ]
      |> Enum.each(fn {l, r} ->
        assert Double.new(l) == Double.new(r)
      end)
    end

    test "two literals with same value but different lexical form are not equal" do
      [
        {"1", 1.0},
        {"01", 1.0},
        {"1.0E0", 1.0},
        {"1.0E0", "1.0"},
        {"+42", 42.0}
      ]
      |> Enum.each(fn {l, r} ->
        assert Double.new(l) != Double.new(r)
      end)
    end
  end
end
