defmodule XSD.DoubleTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Double,
    id: "double",
    valid: %{
      # input => { value, lexical, canonicalized }
      0 => {0.0, "0.0", "0.0E0"},
      42 => {42.0, "42.0", "4.2E1"},
      0.0e0 => {0.0, "0.0", "0.0E0"},
      1.0e0 => {1.0, "1.0", "1.0E0"},
      :positive_infinity => {:positive_infinity, nil, "INF"},
      :negative_infinity => {:negative_infinity, nil, "-INF"},
      :nan => {:nan, nil, "NaN"},
      "1.0E0" => {1.0e0, nil, "1.0E0"},
      "0.0" => {0.0, "0.0", "0.0E0"},
      "1" => {1.0e0, "1", "1.0E0"},
      "01" => {1.0e0, "01", "1.0E0"},
      "0123" => {1.23e2, "0123", "1.23E2"},
      "-1" => {-1.0e0, "-1", "-1.0E0"},
      "+01.000" => {1.0e0, "+01.000", "1.0E0"},
      "1.0" => {1.0e0, "1.0", "1.0E0"},
      "123.456" => {1.23456e2, "123.456", "1.23456E2"},
      "1.0e+1" => {1.0e1, "1.0e+1", "1.0E1"},
      "1.0e-10" => {1.0e-10, "1.0e-10", "1.0E-10"},
      "123.456e4" => {1.23456e6, "123.456e4", "1.23456E6"},
      "1.E-8" => {1.0e-8, "1.E-8", "1.0E-8"},
      "3E1" => {3.0e1, "3E1", "3.0E1"},
      "INF" => {:positive_infinity, nil, "INF"},
      "Inf" => {:positive_infinity, "Inf", "INF"},
      "-INF" => {:negative_infinity, nil, "-INF"},
      "NaN" => {:nan, nil, "NaN"}
    },
    invalid: ["foo", "12.xyz", "1.0ez", "+INF", true, false, "1.1e1 foo", "foo 1.1e1"]
end
