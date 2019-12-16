defmodule XSD.StringTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.String,
    name: "string",
    valid: %{
      # input => { value, lexical, canonicalized }
      "foo" => {"foo", nil, "foo"},
      0 => {"0", nil, "0"},
      42 => {"42", nil, "42"},
      3.14 => {"3.14", nil, "3.14"},
      true => {"true", nil, "true"},
      false => {"false", nil, "false"}
    },
    invalid: []

  describe "cast/1" do
    test "casting a string returns the input as it is" do
      assert XSD.string("foo") |> XSD.String.cast() == XSD.string("foo")
    end

    test "casting an integer" do
      assert XSD.integer(0) |> XSD.String.cast() == XSD.string("0")
      assert XSD.integer(1) |> XSD.String.cast() == XSD.string("1")
    end

    test "casting a boolean" do
      assert XSD.false() |> XSD.String.cast() == XSD.string("false")
      assert XSD.true() |> XSD.String.cast() == XSD.string("true")
    end

    test "casting a decimal" do
      assert XSD.decimal(0) |> XSD.String.cast() == XSD.string("0")
      assert XSD.decimal(1.0) |> XSD.String.cast() == XSD.string("1")
      assert XSD.decimal(3.14) |> XSD.String.cast() == XSD.string("3.14")
    end

    test "casting a double" do
      assert XSD.double(0) |> XSD.String.cast() == XSD.string("0")
      assert XSD.double(0.0) |> XSD.String.cast() == XSD.string("0")
      assert XSD.double("+0") |> XSD.String.cast() == XSD.string("0")
      assert XSD.double("-0") |> XSD.String.cast() == XSD.string("-0")
      assert XSD.double(0.1) |> XSD.String.cast() == XSD.string("0.1")
      assert XSD.double(3.14) |> XSD.String.cast() == XSD.string("3.14")
      assert XSD.double(0.000_001) |> XSD.String.cast() == XSD.string("0.000001")
      assert XSD.double(123_456) |> XSD.String.cast() == XSD.string("123456")
      assert XSD.double(1_234_567) |> XSD.String.cast() == XSD.string("1.234567E6")
      assert XSD.double(0.0000001) |> XSD.String.cast() == XSD.string("1.0E-7")
      assert XSD.double(1.0e-10) |> XSD.String.cast() == XSD.string("1.0E-10")
      assert XSD.double("1.0e-10") |> XSD.String.cast() == XSD.string("1.0E-10")
      assert XSD.double(1.26743223e15) |> XSD.String.cast() == XSD.string("1.26743223E15")

      assert XSD.double(:nan) |> XSD.String.cast() == XSD.string("NaN")
      assert XSD.double(:positive_infinity) |> XSD.String.cast() == XSD.string("INF")
      assert XSD.double(:negative_infinity) |> XSD.String.cast() == XSD.string("-INF")
    end

    @tag skip: "TODO: XSD.Float datatype"
    test "casting a float"

    test "casting a datetime" do
      assert XSD.datetime(~N[2010-01-01T12:34:56]) |> XSD.String.cast() ==
               XSD.string("2010-01-01T12:34:56")

      assert XSD.datetime("2010-01-01T00:00:00+00:00") |> XSD.String.cast() ==
               XSD.string("2010-01-01T00:00:00Z")

      assert XSD.datetime("2010-01-01T01:00:00+01:00") |> XSD.String.cast() ==
               XSD.string("2010-01-01T01:00:00+01:00")

      assert XSD.datetime("2010-01-01 01:00:00+01:00") |> XSD.String.cast() ==
               XSD.string("2010-01-01T01:00:00+01:00")
    end

    test "casting a date" do
      assert XSD.date(~D[2000-01-01]) |> XSD.String.cast() == XSD.string("2000-01-01")
      assert XSD.date("2000-01-01") |> XSD.String.cast() == XSD.string("2000-01-01")
      assert XSD.date("2000-01-01+00:00") |> XSD.String.cast() == XSD.string("2000-01-01Z")
      assert XSD.date("2000-01-01+01:00") |> XSD.String.cast() == XSD.string("2000-01-01+01:00")
      assert XSD.date("0001-01-01") |> XSD.String.cast() == XSD.string("0001-01-01")

      unless Version.compare(System.version(), "1.7.2") == :lt do
        assert XSD.date("-0001-01-01") |> XSD.String.cast() == XSD.string("-0001-01-01")
      end
    end

    test "casting a time" do
      assert XSD.time(~T[00:00:00]) |> XSD.String.cast() == XSD.string("00:00:00")
      assert XSD.time("00:00:00") |> XSD.String.cast() == XSD.string("00:00:00")
      assert XSD.time("00:00:00Z") |> XSD.String.cast() == XSD.string("00:00:00Z")
      assert XSD.time("00:00:00+00:00") |> XSD.String.cast() == XSD.string("00:00:00Z")
      assert XSD.time("00:00:00+01:00") |> XSD.String.cast() == XSD.string("00:00:00+01:00")
    end

    test "with invalid literals" do
      assert XSD.integer(3.14) |> XSD.String.cast() == nil
      assert XSD.decimal("NAN") |> XSD.String.cast() == nil
      assert XSD.double(true) |> XSD.String.cast() == nil
    end

    test "with non-XSD-typed values" do
      assert XSD.String.cast(:foo) == nil
    end
  end
end
