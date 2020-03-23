defmodule XSD.EqualityTest do
  use ExUnit.Case

  describe "XSD.String" do
    @term_equal_strings [
      {XSD.string("foo"), XSD.string("foo")}
    ]
    @value_equal_strings []
    @unequal_strings [
      {XSD.string("foo"), XSD.string("bar")}
    ]
    @incomparable_strings [
      {XSD.string("42"), 42}
    ]

    test "term equality", do: assert_term_equal(@term_equal_strings)
    test "value equality", do: assert_value_equal(@value_equal_strings)
    test "inequality", do: assert_unequal(@unequal_strings)
    test "incomparability", do: assert_incomparable(@incomparable_strings)
  end

  describe "XSD.Boolean" do
    @term_equal_booleans [
      {XSD.true(), XSD.true()},
      {XSD.false(), XSD.false()}
    ]
    @value_equal_booleans [
      {XSD.true(), XSD.boolean("1")},
      {XSD.boolean("0"), XSD.false()}
    ]
    @unequal_booleans [
      {XSD.true(), XSD.false()},
      {XSD.false(), XSD.true()},
      {XSD.true(), XSD.boolean("false")},
      {XSD.true(), XSD.boolean("True")},
      {XSD.true(), XSD.boolean(0)},
      {XSD.false(), XSD.boolean("FALSE")}
    ]
    @equal_invalid_booleans [
      {XSD.boolean("foo"), XSD.boolean("foo")}
    ]
    @unequal_invalid_booleans [
      {XSD.boolean("foo"), XSD.boolean("bar")}
    ]
    @incomparable_booleans [
      {XSD.false(), nil},
      {XSD.true(), 42},
      {XSD.true(), XSD.string("FALSE")},
      {XSD.true(), XSD.integer(0)},
      {XSD.true(), XSD.non_negative_integer(0)}
    ]

    test "term equality", do: assert_term_equal(@term_equal_booleans)
    test "value equality", do: assert_value_equal(@value_equal_booleans)
    test "inequality", do: assert_unequal(@unequal_booleans)
    test "invalid equality", do: assert_equal_invalid(@equal_invalid_booleans)
    test "invalid inequality", do: assert_unequal_invalid(@unequal_invalid_booleans)
    test "incomparability", do: assert_incomparable(@incomparable_booleans)
  end

  describe "XSD.Numeric" do
    @term_equal_numerics [
      {XSD.integer(42), XSD.integer(42)},
      {XSD.integer(42), XSD.integer("42")},
      {XSD.integer("042"), XSD.integer("042")},
      {XSD.double("1.0"), XSD.double(1.0)},
      {XSD.double("-42.0"), XSD.double(-42.0)},
      {XSD.double("1.0"), XSD.double(1.0)},
      {XSD.decimal("1.0"), XSD.decimal(1.0)},
      {XSD.decimal("-42.0"), XSD.decimal(-42.0)},
      {XSD.decimal("1.0"), XSD.decimal(1.0)}
    ]
    @value_equal_numerics [
      {XSD.integer("42"), XSD.non_negative_integer("42")},
      {XSD.integer("42"), XSD.positive_integer("42")},
      {XSD.integer("42"), XSD.double("42")},
      {XSD.integer("42"), XSD.decimal("42")},
      {XSD.double(3.14), XSD.decimal(3.14)},
      {XSD.integer(42), XSD.integer("042")},
      {XSD.integer("42"), XSD.integer("042")},
      {XSD.integer(42), XSD.integer("+42")},
      {XSD.integer("42"), XSD.integer("+42")},
      {XSD.integer(42), XSD.decimal(42.0)},
      {XSD.integer(42), XSD.double(42.0)},
      {XSD.non_negative_integer(42), XSD.decimal(42.0)},
      {XSD.non_negative_integer(42), XSD.double(42.0)},
      {XSD.positive_integer(42), XSD.decimal(42.0)},
      {XSD.positive_integer(42), XSD.double(42.0)},
      {XSD.double("+0"), XSD.double("-0")},
      {XSD.double("1"), XSD.double(1.0)},
      {XSD.double("01"), XSD.double(1.0)},
      {XSD.double("1.0E0"), XSD.double(1.0)},
      {XSD.double("1.0E0"), XSD.double("1.0")},
      {XSD.double("+42"), XSD.double(42.0)},
      {XSD.decimal("+0"), XSD.decimal("-0")},
      {XSD.decimal("1"), XSD.decimal(1.0)},
      {XSD.decimal("01"), XSD.decimal(1.0)},
      {XSD.decimal("+42"), XSD.decimal(42.0)}
    ]
    @unequal_numerics [
      {XSD.integer(1), XSD.integer(2)},
      {XSD.integer("1"), XSD.double("1.1")},
      {XSD.integer("1"), XSD.decimal("1.1")}
    ]
    @equal_invalid_numerics [
      {XSD.integer("foo"), XSD.integer("foo")},
      {XSD.decimal("foo"), XSD.decimal("foo")},
      {XSD.double("foo"), XSD.double("foo")},
      {XSD.non_negative_integer("foo"), XSD.non_negative_integer("foo")},
      {XSD.positive_integer("foo"), XSD.positive_integer("foo")}
    ]
    @unequal_invalid_numerics [
      {XSD.integer("foo"), XSD.integer("bar")},
      {XSD.decimal("foo"), XSD.decimal("bar")},
      {XSD.decimal("1.0E0"), XSD.decimal(1.0)},
      {XSD.decimal("1.0E0"), XSD.decimal("1.0")},
      {XSD.double("foo"), XSD.double("bar")},
      {XSD.non_negative_integer("foo"), XSD.non_negative_integer("bar")},
      {XSD.positive_integer("foo"), XSD.positive_integer("bar")}
    ]
    @incomparable_numerics [
      {XSD.integer("42"), nil},
      {XSD.integer("42"), true},
      {XSD.integer("42"), "42"},
      {XSD.integer("42"), XSD.string("42")}
    ]

    test "term equality", do: assert_term_equal(@term_equal_numerics)
    test "value equality", do: assert_value_equal(@value_equal_numerics)
    test "inequality", do: assert_unequal(@unequal_numerics)
    test "invalid equality", do: assert_equal_invalid(@equal_invalid_numerics)
    test "invalid inequality", do: assert_unequal_invalid(@unequal_invalid_numerics)
    test "incomparability", do: assert_incomparable(@incomparable_numerics)

    test "NaN is not equal to itself" do
      refute XSD.Double.equal_value?(XSD.double(:nan), XSD.double(:nan))
    end
  end

  describe "XSD.DateTime" do
    @term_equal_datetimes [
      {XSD.datetime("2002-04-02T12:00:00-01:00"), XSD.datetime("2002-04-02T12:00:00-01:00")},
      {XSD.datetime("2002-04-02T12:00:00"), XSD.datetime("2002-04-02T12:00:00")}
    ]
    @value_equal_datetimes [
      {XSD.datetime("2002-04-02T12:00:00-01:00"), XSD.datetime("2002-04-02T17:00:00+04:00")},
      {XSD.datetime("2002-04-02T23:00:00-04:00"), XSD.datetime("2002-04-03T02:00:00-01:00")},
      {XSD.datetime("1999-12-31T24:00:00"), XSD.datetime("2000-01-01T00:00:00")},
      {XSD.datetime("2002-04-02T23:00:00Z"), XSD.datetime("2002-04-02T23:00:00+00:00")},
      {XSD.datetime("2002-04-02T23:00:00Z"), XSD.datetime("2002-04-02T23:00:00-00:00")},
      {XSD.datetime("2010-01-01T00:00:00+00:00"), XSD.datetime("2010-01-01T00:00:00Z")},
      {XSD.datetime("2002-04-02T23:00:00+00:00"), XSD.datetime("2002-04-02T23:00:00-00:00")},
      {XSD.datetime("2010-01-01T00:00:00.0000Z"), XSD.datetime("2010-01-01T00:00:00Z")},
      {XSD.datetime("2005-04-04T24:00:00"), XSD.datetime("2005-04-05T00:00:00")}
    ]
    @unequal_datetimes [
      {XSD.datetime("2002-04-02T12:00:00"), XSD.datetime("2002-04-02T17:00:00")},
      {XSD.datetime("2005-04-04T24:00:00"), XSD.datetime("2005-04-04T00:00:00")}
    ]
    @equal_invalid_datetimes [
      {XSD.datetime("foo"), XSD.datetime("foo")}
    ]
    @unequal_invalid_datetimes [
      {XSD.datetime("foo"), XSD.datetime("bar")}
    ]
    @incomparable_datetimes [
      {XSD.datetime("2002-04-02T12:00:00"), XSD.datetime("2002-04-02T12:00:00Z")},
      {XSD.datetime("2010-01-01T00:00:00Z"), XSD.datetime("2010-01-01T00:00:00")},
      {XSD.string("2002-04-02T12:00:00-01:00"), XSD.datetime("2002-04-02T12:00:00-01:00")},
      # These are incomparable because of indeterminacy due to missing timezone
      {XSD.datetime("2002-04-02T12:00:00"), XSD.datetime("2002-04-02T23:00:00+00:00")}
    ]

    test "term equality", do: assert_term_equal(@term_equal_datetimes)
    test "value equality", do: assert_value_equal(@value_equal_datetimes)
    test "inequality", do: assert_unequal(@unequal_datetimes)
    test "invalid equality", do: assert_equal_invalid(@equal_invalid_datetimes)
    test "invalid inequality", do: assert_unequal_invalid(@unequal_invalid_datetimes)
    test "incomparability", do: assert_incomparable(@incomparable_datetimes)
  end

  describe "XSD.Date" do
    @term_equal_dates [
      {XSD.date("2002-04-02-01:00"), XSD.date("2002-04-02-01:00")},
      {XSD.date("2002-04-02"), XSD.date("2002-04-02")}
    ]
    @value_equal_dates [
      {XSD.date("2002-04-02-00:00"), XSD.date("2002-04-02+00:00")},
      {XSD.date("2002-04-02Z"), XSD.date("2002-04-02+00:00")},
      {XSD.date("2002-04-02Z"), XSD.date("2002-04-02-00:00")},
    ]
    @unequal_dates [
      {XSD.date("2002-04-01"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-03"), XSD.date("2002-04-02Z")},
      {XSD.date("2002-04-03Z"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-03+00:00"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-03-00:00"), XSD.date("2002-04-02")},
    ]
    @equal_invalid_dates [
      {XSD.date("foo"), XSD.date("foo")}
    ]
    @unequal_invalid_dates [
      {XSD.date("2002.04.02"), XSD.date("2002-04-02")},
      {XSD.date("foo"), XSD.date("bar")}
    ]
    @incomparable_dates [
      {XSD.date("2002-04-02"), XSD.string("2002-04-02")},
      # These are incomparable because of indeterminacy due to missing timezone
      {XSD.date("2002-04-02Z"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-02"), XSD.date("2002-04-02Z")},
      {XSD.date("2010-01-01Z"), XSD.date(~D[2010-01-01])},
      {XSD.date("2010-01-01+00:00"), XSD.date(~D[2010-01-01])},
      {XSD.date("2002-04-02+00:00"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-02-00:00"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-02+01:00"), Date.from_iso8601!("2002-04-02")},
      {XSD.date("2002-04-02Z"), Date.from_iso8601!("2002-04-02")},
      {XSD.date("2002-04-02+00:00"), Date.from_iso8601!("2002-04-02")},
      {XSD.date("2002-04-02-00:00"), Date.from_iso8601!("2002-04-02")}
    ]

    test "term equality", do: assert_term_equal(@term_equal_dates)
    test "value equality", do: assert_value_equal(@value_equal_dates)
    test "inequality", do: assert_unequal(@unequal_dates)
    test "invalid equality", do: assert_equal_invalid(@equal_invalid_dates)
    test "invalid inequality", do: assert_unequal_invalid(@unequal_invalid_dates)
    test "incomparability", do: assert_incomparable(@incomparable_dates)
  end

  describe "equality between XSD.Date and XSD.DateTime" do
    @equal_dates_and_datetimes [
      {XSD.date("2002-04-02"), XSD.datetime("2002-04-02T00:00:00")},
      {XSD.datetime("2002-04-02T00:00:00"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-01"), XSD.datetime("2002-04-02T00:00:00")},
      {XSD.datetime("2002-04-01T00:00:00"), XSD.date("2002-04-02")}
    ]

    test "inequality", do: assert_unequal(@equal_dates_and_datetimes)
  end

  describe "XSD.Time" do
    @term_equal_times [
      {XSD.time("12:00:00+01:00"), XSD.time("12:00:00+01:00")},
      {XSD.time("12:00:00"), XSD.time("12:00:00")}
    ]
    @value_equal_times [
      {XSD.time("00:00:00+00:00"), XSD.time("00:00:00Z")},
    ]
    @unequal_times [
      {XSD.time("12:00:00"), XSD.time("13:00:00")},
      {XSD.time("00:00:00.0000Z"), XSD.time("00:00:00Z")},
    ]
    @equal_invalid_times [
      {XSD.time("foo"), XSD.time("foo")}
    ]
    @unequal_invalid_times [
      {XSD.time("foo"), XSD.time("bar")}
    ]
    @incomparable_times [
      {XSD.time("12:00:00"), XSD.string("12:00:00")},
      {XSD.time("00:00:00"), XSD.time("00:00:00Z")},
      {XSD.time("00:00:00.0000"), XSD.time("00:00:00Z")},
    ]

    test "term equality", do: assert_term_equal(@term_equal_times)
    test "value equality", do: assert_value_equal(@value_equal_times)
    test "inequality", do: assert_unequal(@unequal_times)
    test "invalid equality", do: assert_equal_invalid(@equal_invalid_times)
    test "invalid inequality", do: assert_unequal_invalid(@unequal_invalid_times)
    test "incomparability", do: assert_incomparable(@incomparable_times)
  end

  defp assert_term_equal(examples) do
    Enum.each(examples, fn example -> assert_equality(example, true) end)
    Enum.each(examples, fn example -> assert_term_equality(example, true) end)
    Enum.each(examples, fn example -> assert_value_equality(example, true) end)
  end

  defp assert_value_equal(examples) do
    Enum.each(examples, fn example -> assert_equality(example, false) end)
    Enum.each(examples, fn example -> assert_term_equality(example, false) end)
    Enum.each(examples, fn example -> assert_value_equality(example, true) end)
  end

  defp assert_unequal(examples) do
    Enum.each(examples, fn example -> assert_equality(example, false) end)
    Enum.each(examples, fn example -> assert_term_equality(example, false) end)
    Enum.each(examples, fn example -> assert_value_equality(example, false) end)
  end

  def assert_equal_invalid(examples) do
    Enum.each(examples, fn example -> assert_equality(example, true) end)
    Enum.each(examples, fn example -> assert_term_equality(example, true) end)
    Enum.each(examples, fn example -> assert_value_equality(example, true) end)
  end

  def assert_unequal_invalid(examples) do
    Enum.each(examples, fn example -> assert_equality(example, false) end)
    Enum.each(examples, fn example -> assert_term_equality(example, false) end)
    Enum.each(examples, fn example -> assert_value_equality(example, false) end)
  end

  defp assert_incomparable(examples) do
    Enum.each(examples, fn example -> assert_equality(example, false) end)
    Enum.each(examples, fn example -> assert_term_equality(example, false) end)
    Enum.each(examples, fn example -> assert_value_equality(example, false) end)
  end

  defp assert_equality({left, right}, expected) do
    result = left == right

    assert result == expected, """
    expected #{inspect(left)} == #{inspect(right)})
    to be:   #{inspect(expected)}
    but got: #{inspect(result)}
    """
  end

  defp assert_term_equality({left, right}, expected) do
    result = XSD.Literal.equal?(left, right)

    assert result == expected, """
    expected XSD.Term.equal?(
      #{inspect(left)},
      #{inspect(right)})
    to be:   #{inspect(expected)}
    but got: #{inspect(result)}
    """

    result = XSD.Literal.equal?(right, left)

    assert result == expected, """
    expected XSD.Term.equal?(
      #{inspect(right)},
      #{inspect(left)})
    to be:   #{inspect(expected)}
    but got: #{inspect(result)}
    """
  end

  defp assert_value_equality({left, right}, expected) do
    result = XSD.Literal.equal_value?(left, right)

    assert result == expected, """
    expected XSD.Term.equal_value?(
      #{inspect(left)},
      #{inspect(right)})
    to be:   #{inspect(expected)}
    but got: #{inspect(result)}
    """

    result = XSD.Literal.equal_value?(right, left)

    assert result == expected, """
    expected XSD.Term.equal_value?(
      #{inspect(right)},
      #{inspect(left)})
    to be:   #{inspect(expected)}
    but got: #{inspect(result)}
    """
  end
end
