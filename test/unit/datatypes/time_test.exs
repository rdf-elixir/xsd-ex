defmodule XSD.TimeTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Time,
    name: "time",
    valid: %{
      # input => { value, lexical, canonicalized }
      ~T[00:00:00] => {~T[00:00:00], nil, "00:00:00"},
      ~T[00:00:00.123] => {~T[00:00:00.123], nil, "00:00:00.123"},
      "00:00:00" => {~T[00:00:00], nil, "00:00:00"},
      "00:00:00.123" => {~T[00:00:00.123], nil, "00:00:00.123"},
      "00:00:00Z" => {{~T[00:00:00], true}, nil, "00:00:00Z"},
      "00:00:00.1234Z" => {{~T[00:00:00.1234], true}, nil, "00:00:00.1234Z"},
      "00:00:00.0000Z" => {{~T[00:00:00.0000], true}, nil, "00:00:00.0000Z"},
      "00:00:00+00:00" => {{~T[00:00:00], true}, "00:00:00+00:00", "00:00:00Z"},
      "00:00:00-00:00" => {{~T[00:00:00], true}, "00:00:00-00:00", "00:00:00Z"},
      "01:00:00+01:00" => {{~T[00:00:00], true}, "01:00:00+01:00", "00:00:00Z"},
      "23:00:00-01:00" => {{~T[00:00:00], true}, "23:00:00-01:00", "00:00:00Z"},
      "23:00:00.45-01:00" => {{~T[00:00:00.45], true}, "23:00:00.45-01:00", "00:00:00.45Z"}
    },
    invalid: [
      "foo",
      "+2010-01-01Z",
      "2010-01-01TFOO",
      "02010-01-01",
      "2010-1-1",
      "0000-01-01",
      "2011-07",
      "2011",
      true,
      false,
      2010,
      3.14,
      "00:00:00Z foo",
      "foo 00:00:00Z",
      # this value representation is just internal and not accepted as
      {~T[00:00:00], true},
      {~T[00:00:00], "Z"}
    ]

  describe "new/2" do
    test "with date and tz opt" do
      assert XSD.Time.new("12:00:00", tz: "+01:00") ==
               %XSD.Time{
                 value: {~T[11:00:00], true},
                 uncanonical_lexical: "12:00:00+01:00"
               }

      assert XSD.Time.new(~T[12:00:00], tz: "+01:00") ==
               %XSD.Time{
                 value: {~T[11:00:00], true},
                 uncanonical_lexical: "12:00:00+01:00"
               }

      assert XSD.Time.new("12:00:00", tz: "+00:00") ==
               %XSD.Time{
                 value: {~T[12:00:00], true},
                 uncanonical_lexical: "12:00:00+00:00"
               }

      assert XSD.Time.new(~T[12:00:00], tz: "+00:00") ==
               %XSD.Time{
                 value: {~T[12:00:00], true},
                 uncanonical_lexical: "12:00:00+00:00"
               }
    end

    test "with date string including a timezone and tz opt" do
      assert XSD.Time.new("12:00:00+00:00", tz: "+01:00") ==
               %XSD.Time{
                 value: {~T[11:00:00], true},
                 uncanonical_lexical: "12:00:00+01:00"
               }

      assert XSD.Time.new("12:00:00+01:00", tz: "Z") ==
               %XSD.Time{value: {~T[12:00:00], true}}

      assert XSD.Time.new("12:00:00+01:00", tz: "+00:00") ==
               %XSD.Time{
                 value: {~T[12:00:00], true},
                 uncanonical_lexical: "12:00:00+00:00"
               }
    end

    test "with invalid tz opt" do
      assert XSD.Time.new(~T[12:00:00], tz: "+01:00:42") ==
               %XSD.Time{uncanonical_lexical: "12:00:00+01:00:42"}

      assert XSD.Time.new("12:00:00:foo", tz: "+01:00") ==
               %XSD.Time{uncanonical_lexical: "12:00:00:foo"}

      assert XSD.Time.new("12:00:00", tz: "+01:00:42") ==
               %XSD.Time{uncanonical_lexical: "12:00:00"}

      assert XSD.Time.new("12:00:00+00:00:", tz: "+01:00:") ==
               %XSD.Time{uncanonical_lexical: "12:00:00+00:00:"}
    end
  end

  describe "cast/1" do
    test "casting a time returns the input as it is" do
      assert XSD.time("01:00:00") |> XSD.Time.cast() ==
               XSD.time("01:00:00")
    end

    test "casting a string" do
      assert XSD.string("01:00:00") |> XSD.Time.cast() ==
               XSD.time("01:00:00")

      assert XSD.string("01:00:00Z") |> XSD.Time.cast() ==
               XSD.time("01:00:00Z")

      assert XSD.string("01:00:00+01:00") |> XSD.Time.cast() ==
               XSD.time("01:00:00+01:00")
    end

    test "casting a datetime" do
      assert XSD.datetime("2010-01-01T01:00:00") |> XSD.Time.cast() ==
               XSD.time("01:00:00")

      assert XSD.datetime("2010-01-01T00:00:00Z") |> XSD.Time.cast() ==
               XSD.time("00:00:00Z")

      assert XSD.datetime("2010-01-01T00:00:00+00:00") |> XSD.Time.cast() ==
               XSD.time("00:00:00Z")

      assert XSD.datetime("2010-01-01T23:00:00+01:00") |> XSD.Time.cast() ==
               XSD.time("23:00:00+01:00")
    end

    test "with invalid literals" do
      assert XSD.time("25:00:00") |> XSD.Time.cast() == nil
      assert XSD.datetime("02010-01-01T00:00:00") |> XSD.Time.cast() == nil
    end

    test "with literals of unsupported datatypes" do
      assert XSD.false() |> XSD.Time.cast() == nil
      assert XSD.integer(1) |> XSD.Time.cast() == nil
      assert XSD.decimal(3.14) |> XSD.Time.cast() == nil
    end

    test "with coercible value" do
      assert XSD.Time.cast("01:00:00") == XSD.time("01:00:00")
    end

    test "with non-coercible value" do
      assert XSD.Time.cast(:foo) == nil
      assert XSD.Time.cast(make_ref()) == nil
    end
  end

  describe "Elixir equality" do
    test "two literals are equal when they have the same datatype and lexical form" do
      [
        {~T[00:00:00], "00:00:00"}
      ]
      |> Enum.each(fn {l, r} ->
        assert Time.new(l) == Time.new(r)
      end)
    end

    test "two literals with same value but different lexical form are not equal" do
      [
        {~T[00:00:00], "00:00:00Z"},
        {"00:00:00", "00:00:00Z"},
        {"00:00:00.0000", "00:00:00Z"},
        {"00:00:00.0000Z", "00:00:00Z"},
        {"00:00:00+00:00", "00:00:00Z"}
      ]
      |> Enum.each(fn {l, r} ->
        assert Time.new(l) != Time.new(r)
      end)
    end
  end
end
