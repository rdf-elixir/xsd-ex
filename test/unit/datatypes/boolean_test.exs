defmodule XSD.BooleanTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Boolean,
    name: "boolean",
    valid: %{
      # input => { value, lexical, canonicalized }
      true => {true, nil, "true"},
      false => {false, nil, "false"},
      0 => {false, nil, "false"},
      1 => {true, nil, "true"},
      "true" => {true, nil, "true"},
      "false" => {false, nil, "false"},
      "0" => {false, "0", "false"},
      "1" => {true, "1", "true"}
    },
    invalid: ["foo", "10", 42, 3.14, "tRuE", "FaLsE", "true false", "true foo"]

  describe "cast/1" do
    test "casting a boolean returns the input as it is" do
      assert XSD.true() |> XSD.Boolean.cast() == XSD.true()
      assert XSD.false() |> XSD.Boolean.cast() == XSD.false()
    end

    test "casting a string with a value from the lexical value space of xsd:boolean" do
      assert XSD.string("true") |> XSD.Boolean.cast() == XSD.true()
      assert XSD.string("1") |> XSD.Boolean.cast() == XSD.true()

      assert XSD.string("false") |> XSD.Boolean.cast() == XSD.false()
      assert XSD.string("0") |> XSD.Boolean.cast() == XSD.false()
    end

    test "casting a string with a value not in the lexical value space of xsd:boolean" do
      assert XSD.string("foo") |> XSD.Boolean.cast() == nil
    end

    test "casting an integer" do
      assert XSD.integer(0) |> XSD.Boolean.cast() == XSD.false()
      assert XSD.integer(1) |> XSD.Boolean.cast() == XSD.true()
      assert XSD.integer(42) |> XSD.Boolean.cast() == XSD.true()
    end

    test "casting a decimal" do
      assert XSD.decimal(0) |> XSD.Boolean.cast() == XSD.false()
      assert XSD.decimal(0.0) |> XSD.Boolean.cast() == XSD.false()
      assert XSD.decimal("+0") |> XSD.Boolean.cast() == XSD.false()
      assert XSD.decimal("-0") |> XSD.Boolean.cast() == XSD.false()
      assert XSD.decimal("+0.0") |> XSD.Boolean.cast() == XSD.false()
      assert XSD.decimal("-0.0") |> XSD.Boolean.cast() == XSD.false()
      assert XSD.decimal(0.0e0) |> XSD.Boolean.cast() == XSD.false()

      assert XSD.decimal(1) |> XSD.Boolean.cast() == XSD.true()
      assert XSD.decimal(0.1) |> XSD.Boolean.cast() == XSD.true()
    end

    test "casting a double" do
      assert XSD.double(0) |> XSD.Boolean.cast() == XSD.false()
      assert XSD.double(0.0) |> XSD.Boolean.cast() == XSD.false()
      assert XSD.double("+0") |> XSD.Boolean.cast() == XSD.false()
      assert XSD.double("-0") |> XSD.Boolean.cast() == XSD.false()
      assert XSD.double("+0.0") |> XSD.Boolean.cast() == XSD.false()
      assert XSD.double("-0.0") |> XSD.Boolean.cast() == XSD.false()
      assert XSD.double("0.0E0") |> XSD.Boolean.cast() == XSD.false()
      assert XSD.double("NAN") |> XSD.Boolean.cast() == XSD.false()

      assert XSD.double(1) |> XSD.Boolean.cast() == XSD.true()
      assert XSD.double(0.1) |> XSD.Boolean.cast() == XSD.true()
      assert XSD.double("-INF") |> XSD.Boolean.cast() == XSD.true()
    end

    @tag skip: "TODO: XSD.Float datatype"
    test "casting a float"

    test "with invalid literals" do
      assert XSD.boolean("42") |> XSD.Boolean.cast() == nil
      assert XSD.integer(3.14) |> XSD.Boolean.cast() == nil
      assert XSD.decimal("NAN") |> XSD.Boolean.cast() == nil
      assert XSD.double(true) |> XSD.Boolean.cast() == nil
    end

    test "with values of unsupported datatypes" do
      assert XSD.date("2020-01-01") |> XSD.Boolean.cast() == nil
    end

    test "with non-XSD-typed value" do
      assert XSD.Boolean.cast(:foo) == nil
      assert XSD.Boolean.cast(42) == nil
    end
  end

  describe "Elixir equality" do
    test "two literals are equal when they have the same datatype and lexical form" do
      [
        {true, "true"},
        {false, "false"},
        {1, "true"},
        {0, "false"}
      ]
      |> Enum.each(fn {l, r} ->
        assert Boolean.new(l) == Boolean.new(r)
      end)
    end

    test "two literals with same value but different lexical form are not equal" do
      [
        {"True", "true"},
        {"FALSE", "false"},
        {"1", "true"},
        {"0", "false"}
      ]
      |> Enum.each(fn {l, r} ->
        assert Boolean.new(l) != Boolean.new(r)
      end)
    end
  end
end
