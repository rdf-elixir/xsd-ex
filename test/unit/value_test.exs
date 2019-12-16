defmodule XSD.ValueTest do
  use ExUnit.Case

  alias Decimal, as: D

  describe "coerce/1" do
    test "with boolean" do
      assert XSD.Value.coerce(true) == XSD.true()
      assert XSD.Value.coerce(false) == XSD.false()
    end

    test "with string" do
      assert XSD.Value.coerce("foo") == XSD.string("foo")
    end

    test "with integer" do
      assert XSD.Value.coerce(42) == XSD.integer(42)
    end

    test "with float" do
      assert XSD.Value.coerce(3.14) == XSD.double(3.14)
    end

    test "with decimal" do
      assert D.from_float(3.14) |> XSD.Value.coerce() == XSD.decimal(3.14)
    end

    test "with datetime" do
      assert DateTime.from_iso8601("2002-04-02T12:00:00+00:00") |> elem(1) |> XSD.Value.coerce() ==
               DateTime.from_iso8601("2002-04-02T12:00:00+00:00") |> elem(1) |> XSD.datetime()
    end

    test "with naive datetime" do
      assert ~N"2002-04-02T12:00:00" |> XSD.Value.coerce() ==
               ~N"2002-04-02T12:00:00" |> XSD.datetime()
    end

    test "with date" do
      assert ~D"2002-04-02" |> XSD.Value.coerce() ==
               ~D"2002-04-02" |> XSD.date()
    end

    test "with time" do
      assert ~T"12:00:00" |> XSD.Value.coerce() ==
               ~T"12:00:00" |> XSD.time()
    end

    test "with inconvertible values" do
      assert self() |> XSD.Value.coerce() == nil
    end
  end
end
