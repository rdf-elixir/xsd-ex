defmodule XSD.BooleanTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Boolean,
    id: "string",
    valid: %{
      # input => { value, lexical, canonicalized }
      true => {true, nil, "true"},
      false => {false, nil, "false"},
      0 => {false, nil, "false"},
      1 => {true, nil, "true"},
      "true" => {true, nil, "true"},
      "false" => {false, nil, "false"},
      "0" => {false, "0", "false"},
      "1" => {true, "1", "true"}
    },
    invalid: ["foo", "10", 42, 3.14, "tRuE", "FaLsE", "true false", "true foo"]
end
