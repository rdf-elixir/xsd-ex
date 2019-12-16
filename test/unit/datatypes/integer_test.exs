defmodule XSD.IntegerTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Integer,
    name: "integer",
    valid: %{
      # input => { value, lexical, canonicalized }
      0 => {0, nil, "0"},
      1 => {1, nil, "1"},
      "0" => {0, nil, "0"},
      "1" => {1, nil, "1"},
      "01" => {1, "01", "1"},
      "0123" => {123, "0123", "123"},
      +1 => {1, nil, "1"},
      -1 => {-1, nil, "-1"},
      "+1" => {1, "+1", "1"},
      "-1" => {-1, nil, "-1"}
    },
    invalid: ["foo", "10.1", "12xyz", true, false, 3.14, "1 2", "foo 1", "1 foo"]

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

    @tag skip: "TODO: XSD.Float datatype"
    test "casting a float"

    test "with invalid literals" do
      assert XSD.integer(3.14) |> XSD.Integer.cast() == nil
      assert XSD.decimal("NAN") |> XSD.Integer.cast() == nil
      assert XSD.double(true) |> XSD.Integer.cast() == nil
    end

    test "with literals of unsupported datatypes" do
      assert XSD.date("2020-01-01") |> XSD.Integer.cast() == nil
    end

    test "with non-XSD-typed values" do
      assert XSD.Integer.cast(:foo) == nil
    end
  end

  describe "Elixir equality" do
    test "two literals are equal when they have the same datatype and lexical form" do
      [
        {"1", 1},
        {"-42", -42}
      ]
      |> Enum.each(fn {l, r} ->
        assert Integer.new(l) == Integer.new(r)
      end)
    end

    test "two literals with same value but different lexical form are not equal" do
      [
        {"01", 1},
        {"+42", 42}
      ]
      |> Enum.each(fn {l, r} ->
        assert Integer.new(l) != Integer.new(r)
      end)
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
