defmodule XSD.StringTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.String,
    name: "string",
    valid: %{
      # input => { value, lexical, canonicalized }
      "foo" => {"foo", nil, "foo"},
      0 => {"0", nil, "0"},
      42 => {"42", nil, "42"},
      3.14 => {"3.14", nil, "3.14"},
      true => {"true", nil, "true"},
      false => {"false", nil, "false"}
    },
    invalid: []
end
