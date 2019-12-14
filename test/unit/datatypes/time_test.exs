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
end
