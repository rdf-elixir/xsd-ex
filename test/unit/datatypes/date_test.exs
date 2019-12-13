defmodule XSD.DateTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Date,
    id: "date",
    valid: %{
      # input => { value, lexical, canonicalized }
      ~D[2010-01-01] => {~D[2010-01-01], nil, "2010-01-01"},
      "2010-01-01" => {~D[2010-01-01], nil, "2010-01-01"},
      "2010-01-01Z" => {{~D[2010-01-01], "Z"}, nil, "2010-01-01Z"},
      "2010-01-01+00:00" => {{~D[2010-01-01], "Z"}, "2010-01-01+00:00", "2010-01-01Z"},
      "2010-01-01-00:00" => {{~D[2010-01-01], "-00:00"}, nil, "2010-01-01-00:00"},
      "2010-01-01+01:00" => {{~D[2010-01-01], "+01:00"}, nil, "2010-01-01+01:00"},
      "2009-12-31-01:00" => {{~D[2009-12-31], "-01:00"}, nil, "2009-12-31-01:00"},
      "2014-09-01-08:00" => {{~D[2014-09-01], "-08:00"}, nil, "2014-09-01-08:00"},

      # negative years
      "-2010-01-01" => {~D[-2010-01-01], nil, "-2010-01-01"},
      "-2010-01-01Z" => {{~D[-2010-01-01], "Z"}, nil, "-2010-01-01Z"},
      "-2010-01-01+00:00" => {{~D[-2010-01-01], "Z"}, "-2010-01-01+00:00", "-2010-01-01Z"}
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
      # this value representation is just internal and not accepted as
      {~D[2010-01-01], "Z"}
    ]

  describe "new/2" do
    test "with date and tz opt" do
      assert XSD.Date.new("2010-01-01", tz: "+01:00") ==
               %XSD.Date{value: {~D[2010-01-01], "+01:00"}}

      assert XSD.Date.new(~D[2010-01-01], tz: "+01:00") ==
               %XSD.Date{value: {~D[2010-01-01], "+01:00"}}

      assert XSD.Date.new("2010-01-01", tz: "+00:00") ==
               %XSD.Date{
                 value: {~D[2010-01-01], "Z"},
                 uncanonical_lexical: "2010-01-01+00:00"
               }

      assert XSD.Date.new(~D[2010-01-01], tz: "+00:00") ==
               %XSD.Date{
                 value: {~D[2010-01-01], "Z"},
                 uncanonical_lexical: "2010-01-01+00:00"
               }
    end

    test "with date string including a timezone and tz opt" do
      assert XSD.Date.new("2010-01-01+00:00", tz: "+01:00") ==
               %XSD.Date{value: {~D[2010-01-01], "+01:00"}}

      assert XSD.Date.new("2010-01-01+01:00", tz: "Z") ==
               %XSD.Date{value: {~D[2010-01-01], "Z"}}

      assert XSD.Date.new("2010-01-01+01:00", tz: "+00:00") ==
               %XSD.Date{
                 value: {~D[2010-01-01], "Z"},
                 uncanonical_lexical: "2010-01-01+00:00"
               }
    end

    test "with invalid tz opt" do
      assert XSD.Date.new(~D[2020-01-01], tz: "+01:00:42") ==
               %XSD.Date{uncanonical_lexical: "2020-01-01+01:00:42"}

      assert XSD.Date.new("2020-01-01-01", tz: "+01:00") ==
               %XSD.Date{uncanonical_lexical: "2020-01-01-01"}

      assert XSD.Date.new("2020-01-01", tz: "+01:00:42") ==
               %XSD.Date{uncanonical_lexical: "2020-01-01"}

      assert XSD.Date.new("2020-01-01+00:00:", tz: "+01:00:") ==
               %XSD.Date{uncanonical_lexical: "2020-01-01+00:00:"}
    end
  end
end
