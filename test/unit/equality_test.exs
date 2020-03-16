defmodule XSD.EqualityTest do
  use ExUnit.Case

  describe "XSD.String" do
    @term_equal_strings [
      {XSD.string("foo"), XSD.string("foo")}
    ]
    @term_unequal_strings [
      {XSD.string("foo"), XSD.string("bar")}
    ]
    @value_equal_strings []
    @value_unequal_strings []
    @incomparable_strings [
      {XSD.string("42"), 42}
    ]

    test "term equality", do: assert_term_equal(@term_equal_strings)
    test "term inequality", do: assert_term_unequal(@term_unequal_strings)
    test "value equality", do: assert_value_equal(@value_equal_strings)
    test "value inequality", do: assert_value_unequal(@value_unequal_strings)
    test "incomparability", do: assert_incomparable(@incomparable_strings)
  end

  describe "XSD.Boolean" do
    @term_equal_booleans [
      {XSD.true(), XSD.true()},
      {XSD.false(), XSD.false()},
      # invalid values
      {XSD.boolean("foo"), XSD.boolean("foo")}
    ]
    @term_unequal_booleans [
      {XSD.true(), XSD.false()},
      {XSD.false(), XSD.true()},
      # invalid values
      {XSD.boolean("foo"), XSD.boolean("bar")}
    ]
    @value_equal_booleans [
      {XSD.true(), XSD.boolean("1")},
      {XSD.boolean(0), XSD.false()},
      # invalid values
      {XSD.boolean("foo"), XSD.boolean("foo")}
    ]
    @value_unequal_booleans [
      {XSD.true(), XSD.boolean("false")},
      {XSD.boolean(0), XSD.true()},
      # invalid values
      {XSD.boolean("foo"), XSD.boolean("bar")}
    ]
    @incomparable_booleans [
      {XSD.false(), nil},
      {XSD.true(), 42},
      {XSD.true(), XSD.string("FALSE")},
      {XSD.true(), XSD.integer(0)}
    ]

    test "term equality", do: assert_term_equal(@term_equal_booleans)
    test "term inequality", do: assert_term_unequal(@term_unequal_booleans)
    test "value equality", do: assert_value_equal(@value_equal_booleans)
    test "value inequality", do: assert_value_unequal(@value_unequal_booleans)
    test "incomparability", do: assert_incomparable(@incomparable_booleans)
  end

  describe "XSD.Numeric" do
    @term_equal_numerics [
      {XSD.integer(42), XSD.integer(42)},
      {XSD.integer("042"), XSD.integer("042")},
      # invalid values
      {XSD.integer("foo"), XSD.integer("foo")},
      {XSD.decimal("foo"), XSD.decimal("foo")},
      {XSD.double("foo"), XSD.double("foo")}
    ]
    @term_unequal_numerics [
      {XSD.integer(1), XSD.integer(2)},
      # invalid values
      {XSD.integer("foo"), XSD.integer("bar")},
      {XSD.decimal("foo"), XSD.decimal("bar")},
      {XSD.double("foo"), XSD.double("bar")}
    ]
    @value_equal_numerics [
      {XSD.integer("42"), XSD.integer("042")},
      {XSD.integer("42"), XSD.double("42")},
      {XSD.integer(42), XSD.double(42.0)},
      {XSD.integer("42"), XSD.decimal("42")},
      {XSD.integer(42), XSD.decimal(42.0)},
      {XSD.double(3.14), XSD.decimal(3.14)},
      {XSD.double("+0"), XSD.double("-0")},
      {XSD.decimal("+0"), XSD.decimal("-0")},
      # invalid values
      {XSD.integer("foo"), XSD.integer("foo")},
      {XSD.decimal("foo"), XSD.decimal("foo")},
      {XSD.double("foo"), XSD.double("foo")}
    ]
    @value_unequal_numerics [
      {XSD.integer("1"), XSD.double("1.1")},
      {XSD.integer("1"), XSD.decimal("1.1")},
      # invalid values
      {XSD.integer("foo"), XSD.integer("bar")},
      {XSD.decimal("foo"), XSD.decimal("bar")},
      {XSD.double("foo"), XSD.double("bar")}
    ]
    @incomparable_numerics [
      {XSD.integer("42"), nil},
      {XSD.integer("42"), true},
      {XSD.integer("42"), "42"},
      {XSD.integer("42"), XSD.string("42")}
    ]

    test "term equality", do: assert_term_equal(@term_equal_numerics)
    test "term inequality", do: assert_term_unequal(@term_unequal_numerics)
    test "value equality", do: assert_value_equal(@value_equal_numerics)
    test "value inequality", do: assert_value_unequal(@value_unequal_numerics)
    test "incomparability", do: assert_incomparable(@incomparable_numerics)
  end

  describe "XSD.DateTime" do
    @term_equal_datetimes [
      {XSD.datetime("2002-04-02T12:00:00-01:00"), XSD.datetime("2002-04-02T12:00:00-01:00")},
      {XSD.datetime("2002-04-02T12:00:00"), XSD.datetime("2002-04-02T12:00:00")},
      # invalid values
      {XSD.datetime("foo"), XSD.datetime("foo")}
    ]
    @term_unequal_datetimes [
      {XSD.datetime("2002-04-02T12:00:00"), XSD.datetime("2002-04-02T17:00:00")},
      # invalid values
      {XSD.datetime("foo"), XSD.datetime("bar")}
    ]
    @value_equal_datetimes [
      {XSD.datetime("2002-04-02T12:00:00-01:00"), XSD.datetime("2002-04-02T17:00:00+04:00")},
      {XSD.datetime("2002-04-02T23:00:00-04:00"), XSD.datetime("2002-04-03T02:00:00-01:00")},
      {XSD.datetime("1999-12-31T24:00:00"), XSD.datetime("2000-01-01T00:00:00")},
      {XSD.datetime("2002-04-02T23:00:00Z"), XSD.datetime("2002-04-02T23:00:00+00:00")},
      {XSD.datetime("2002-04-02T23:00:00Z"), XSD.datetime("2002-04-02T23:00:00-00:00")},
      {XSD.datetime("2002-04-02T23:00:00+00:00"), XSD.datetime("2002-04-02T23:00:00-00:00")},

      # invalid values
      {XSD.datetime("foo"), XSD.datetime("foo")}
    ]
    @value_unequal_datetimes [
      {XSD.datetime("2005-04-04T24:00:00"), XSD.datetime("2005-04-04T00:00:00")},
      # invalid values
      {XSD.datetime("foo"), XSD.datetime("bar")}
    ]
    @incomparable_datetimes [
      {XSD.datetime("2002-04-02T12:00:00"), XSD.datetime("2002-04-02T12:00:00Z")},
      {XSD.string("2002-04-02T12:00:00-01:00"), XSD.datetime("2002-04-02T12:00:00-01:00")},
      # These are incomparable because of indeterminacy due to missing timezone
      {XSD.datetime("2002-04-02T12:00:00"), XSD.datetime("2002-04-02T23:00:00+00:00")}
    ]

    test "term equality", do: assert_term_equal(@term_equal_datetimes)
    test "term inequality", do: assert_term_unequal(@term_unequal_datetimes)
    test "value equality", do: assert_value_equal(@value_equal_datetimes)
    test "value inequality", do: assert_value_unequal(@value_unequal_datetimes)
    test "incomparability", do: assert_incomparable(@incomparable_datetimes)
  end

  describe "XSD.Date" do
    @term_equal_dates [
      {XSD.date("2002-04-02-01:00"), XSD.date("2002-04-02-01:00")},
      {XSD.date("2002-04-02"), XSD.date("2002-04-02")},
      # invalid values
      {XSD.date("foo"), XSD.date("foo")}
    ]
    @term_unequal_dates [
      {XSD.date("2002-04-01"), XSD.date("2002-04-02")},
      # invalid values
      {XSD.date("foo"), XSD.date("bar")}
    ]
    @value_equal_dates [
      {XSD.date("2002-04-02-00:00"), XSD.date("2002-04-02+00:00")},
      {XSD.date("2002-04-02Z"), XSD.date("2002-04-02+00:00")},
      {XSD.date("2002-04-02Z"), XSD.date("2002-04-02-00:00")}
    ]
    @value_unequal_dates [
      {XSD.date("2002-04-03Z"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-03"), XSD.date("2002-04-02Z")},
      {XSD.date("2002-04-03+00:00"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-03-00:00"), XSD.date("2002-04-02")},
      # invalid values
      {XSD.date("2002.04.02"), XSD.date("2002-04-02")}
    ]
    @incomparable_dates [
      {XSD.date("2002-04-02"), XSD.string("2002-04-02")},
      # These are incomparable because of indeterminacy due to missing timezone
      {XSD.date("2002-04-02Z"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-02"), XSD.date("2002-04-02Z")},
      {XSD.date("2002-04-02+00:00"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-02-00:00"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-02+01:00"), Date.from_iso8601!("2002-04-02")},
      {XSD.date("2002-04-02Z"), Date.from_iso8601!("2002-04-02")},
      {XSD.date("2002-04-02+00:00"), Date.from_iso8601!("2002-04-02")},
      {XSD.date("2002-04-02-00:00"), Date.from_iso8601!("2002-04-02")}
    ]

    test "term equality", do: assert_term_equal(@term_equal_dates)
    test "term inequality", do: assert_term_unequal(@term_unequal_dates)
    test "value equality", do: assert_value_equal(@value_equal_dates)
    test "value inequality", do: assert_value_unequal(@value_unequal_dates)
    test "incomparability", do: assert_incomparable(@incomparable_dates)
  end

  describe "equality between XSD.Date and XSD.DateTime" do
    @value_unequal_dates_and_datetimes [
      {XSD.date("2002-04-02"), XSD.datetime("2002-04-02T00:00:00")},
      {XSD.datetime("2002-04-02T00:00:00"), XSD.date("2002-04-02")},
      {XSD.date("2002-04-01"), XSD.datetime("2002-04-02T00:00:00")},
      {XSD.datetime("2002-04-01T00:00:00"), XSD.date("2002-04-02")}
    ]

    test "value inequality", do: assert_value_unequal(@value_unequal_dates_and_datetimes)
  end

  describe "XSD.Time" do
    @term_equal_times [
      {XSD.time("12:00:00+01:00"), XSD.time("12:00:00+01:00")},
      {XSD.time("12:00:00"), XSD.time("12:00:00")},
      # invalid values
      {XSD.time("foo"), XSD.time("foo")}
    ]
    @term_unequal_times [
      {XSD.time("12:00:00"), XSD.time("13:00:00")},
      # invalid values
      {XSD.time("foo"), XSD.time("bar")}
    ]
    @value_equal_times []
    @value_unequal_times []
    @incomparable_times [
      {XSD.time("12:00:00"), XSD.string("12:00:00")}
    ]

    test "term equality", do: assert_term_equal(@term_equal_times)
    test "term inequality", do: assert_term_unequal(@term_unequal_times)
    test "value equality", do: assert_value_equal(@value_equal_times)
    test "value inequality", do: assert_value_unequal(@value_unequal_times)
    test "incomparability", do: assert_incomparable(@incomparable_times)
  end

  defp assert_term_equal(examples) do
    Enum.each(examples, fn example -> assert_term_equality(example, true) end)
    Enum.each(examples, fn example -> assert_value_equality(example, true) end)
  end

  defp assert_term_unequal(examples) do
    Enum.each(examples, fn example -> assert_term_equality(example, false) end)
    Enum.each(examples, fn example -> assert_value_equality(example, false) end)
  end

  defp assert_value_equal(examples) do
    Enum.each(examples, fn example -> assert_value_equality(example, true) end)
  end

  defp assert_value_unequal(examples) do
    Enum.each(examples, fn example -> assert_value_equality(example, false) end)
  end

  defp assert_incomparable(examples) do
    Enum.each(examples, fn example -> assert_term_equality(example, false) end)
    Enum.each(examples, fn example -> assert_value_equality(example, false) end)
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
