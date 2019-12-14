defmodule XSD.DateTimeTest do
  import XSD.Datatype.Test.Case, only: [dt: 1]

  use XSD.Datatype.Test.Case,
    datatype: XSD.DateTime,
    name: "dateTime",
    valid: %{
      # input => { value, lexical, canonicalized }
      dt("2010-01-01T00:00:00Z") => {dt("2010-01-01T00:00:00Z"), nil, "2010-01-01T00:00:00Z"},
      ~N[2010-01-01T00:00:00] => {~N[2010-01-01T00:00:00], nil, "2010-01-01T00:00:00"},
      ~N[2010-01-01T00:00:00.00] => {~N[2010-01-01T00:00:00.00], nil, "2010-01-01T00:00:00.00"},
      ~N[2010-01-01T00:00:00.1234] =>
        {~N[2010-01-01T00:00:00.1234], nil, "2010-01-01T00:00:00.1234"},
      dt("2010-01-01T00:00:00+00:00") =>
        {dt("2010-01-01T00:00:00Z"), nil, "2010-01-01T00:00:00Z"},
      dt("2010-01-01T01:00:00+01:00") =>
        {dt("2010-01-01T00:00:00Z"), nil, "2010-01-01T00:00:00Z"},
      dt("2009-12-31T23:00:00-01:00") =>
        {dt("2010-01-01T00:00:00Z"), nil, "2010-01-01T00:00:00Z"},
      dt("2009-12-31T23:00:00.00-01:00") =>
        {dt("2010-01-01T00:00:00.00Z"), nil, "2010-01-01T00:00:00.00Z"},
      "2010-01-01T00:00:00Z" => {dt("2010-01-01T00:00:00Z"), nil, "2010-01-01T00:00:00Z"},
      "2010-01-01T00:00:00.0000Z" =>
        {dt("2010-01-01T00:00:00.0000Z"), nil, "2010-01-01T00:00:00.0000Z"},
      "2010-01-01T00:00:00.123456Z" =>
        {dt("2010-01-01T00:00:00.123456Z"), nil, "2010-01-01T00:00:00.123456Z"},
      "2010-01-01T00:00:00" => {~N[2010-01-01T00:00:00], nil, "2010-01-01T00:00:00"},
      "2010-01-01T00:00:00+00:00" =>
        {dt("2010-01-01T00:00:00Z"), "2010-01-01T00:00:00+00:00", "2010-01-01T00:00:00Z"},
      "2010-01-01T00:00:00-00:00" =>
        {dt("2010-01-01T00:00:00Z"), "2010-01-01T00:00:00-00:00", "2010-01-01T00:00:00Z"},
      "2010-01-01T01:00:00+01:00" =>
        {dt("2010-01-01T00:00:00Z"), "2010-01-01T01:00:00+01:00", "2010-01-01T00:00:00Z"},
      "2009-12-31T23:00:00.42-01:00" =>
        {dt("2010-01-01T00:00:00.42Z"), "2009-12-31T23:00:00.42-01:00", "2010-01-01T00:00:00.42Z"},
      "2009-12-31T23:00:00-01:00" =>
        {dt("2010-01-01T00:00:00Z"), "2009-12-31T23:00:00-01:00", "2010-01-01T00:00:00Z"},

      # 24:00 is a valid XSD dateTime
      "2009-12-31T24:00:00" =>
        {~N[2010-01-01T00:00:00], "2009-12-31T24:00:00", "2010-01-01T00:00:00"},
      "2009-12-31T24:00:00+00:00" =>
        {dt("2010-01-01T00:00:00Z"), "2009-12-31T24:00:00+00:00", "2010-01-01T00:00:00Z"},
      "2009-12-31T24:00:00-00:00" =>
        {dt("2010-01-01T00:00:00Z"), "2009-12-31T24:00:00-00:00", "2010-01-01T00:00:00Z"},

      # negative years
      dt("-2010-01-01T00:00:00Z") => {dt("-2010-01-01T00:00:00Z"), nil, "-2010-01-01T00:00:00Z"},
      "-2010-01-01T00:00:00+00:00" =>
        {dt("-2010-01-01T00:00:00Z"), "-2010-01-01T00:00:00+00:00", "-2010-01-01T00:00:00Z"}
    },
    invalid: [
      "foo",
      "+2010-01-01T00:00:00Z",
      "2010-01-01T00:00:00FOO",
      "02010-01-01T00:00:00",
      "2010-01-01",
      "2010-1-1T00:00:00",
      "0000-01-01T00:00:00",
      "2010-07",
      "2010_",
      true,
      false,
      2010,
      3.14,
      "2010-01-01T00:00:00Z foo",
      "foo 2010-01-01T00:00:00Z"
    ]
end
