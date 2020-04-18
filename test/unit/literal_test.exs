defmodule XSD.LiteralTest do
  use ExUnit.Case

  alias Decimal, as: D

  test "base_primitive/1" do
    assert XSD.integer(42) |> XSD.Literal.base_primitive() == XSD.Integer
    assert XSD.non_negative_integer(42) |> XSD.Literal.base_primitive() == XSD.Integer
    assert XSD.positive_integer(42) |> XSD.Literal.base_primitive() == XSD.Integer
  end

  test "derived_from?/2" do
    assert XSD.integer(42) |> XSD.Literal.derived_from?(XSD.Integer)
    assert XSD.non_negative_integer(42) |> XSD.Literal.derived_from?(XSD.Integer)
    assert XSD.positive_integer(42) |> XSD.Literal.derived_from?(XSD.Integer)
    assert XSD.positive_integer(42) |> XSD.Literal.derived_from?(XSD.NonNegativeInteger)
  end

  describe "coerce/1" do
    test "with boolean" do
      assert XSD.Literal.coerce(true) == XSD.true()
      assert XSD.Literal.coerce(false) == XSD.false()
    end

    test "with string" do
      assert XSD.Literal.coerce("foo") == XSD.string("foo")
    end

    test "with integer" do
      assert XSD.Literal.coerce(42) == XSD.integer(42)
    end

    test "with float" do
      assert XSD.Literal.coerce(3.14) == XSD.double(3.14)
    end

    test "with decimal" do
      assert D.from_float(3.14) |> XSD.Literal.coerce() == XSD.decimal(3.14)
    end

    test "with datetime" do
      assert DateTime.from_iso8601("2002-04-02T12:00:00+00:00") |> elem(1) |> XSD.Literal.coerce() ==
               DateTime.from_iso8601("2002-04-02T12:00:00+00:00") |> elem(1) |> XSD.datetime()
    end

    test "with naive datetime" do
      assert ~N"2002-04-02T12:00:00" |> XSD.Literal.coerce() ==
               ~N"2002-04-02T12:00:00" |> XSD.datetime()
    end

    test "with date" do
      assert ~D"2002-04-02" |> XSD.Literal.coerce() ==
               ~D"2002-04-02" |> XSD.date()
    end

    test "with time" do
      assert ~T"12:00:00" |> XSD.Literal.coerce() ==
               ~T"12:00:00" |> XSD.time()
    end

    test "with URI" do
      assert URI.parse("http://example.com") |> XSD.Literal.coerce() ==
               XSD.any_uri("http://example.com")
    end

    test "with XSD.Literals" do
      assert XSD.integer(42) |> XSD.Literal.coerce() == XSD.integer(42)
    end

    test "with inconvertible values" do
      assert self() |> XSD.Literal.coerce() == nil
    end
  end
end
