defmodule XSD.IntegerTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Integer,
    id: "integer",
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
end
