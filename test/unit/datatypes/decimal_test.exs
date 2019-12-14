defmodule XSD.DecimalTest do
  use XSD.Datatype.Test.Case,
    datatype: XSD.Decimal,
    name: "decimal",
    valid: %{
      # input => {value, lexical, canonicalized}
      0 => {Elixir.Decimal.from_float(0.0), nil, "0.0"},
      1 => {Elixir.Decimal.from_float(1.0), nil, "1.0"},
      -1 => {Elixir.Decimal.from_float(-1.0), nil, "-1.0"},
      1.0 => {Elixir.Decimal.from_float(1.0), nil, "1.0"},
      -3.14 => {Elixir.Decimal.from_float(-3.14), nil, "-3.14"},
      0.0e2 => {Elixir.Decimal.from_float(0.0), nil, "0.0"},
      1.2e3 => {Elixir.Decimal.new("1200.0"), nil, "1200.0"},
      Elixir.Decimal.from_float(1.0) => {Elixir.Decimal.from_float(1.0), nil, "1.0"},
      Elixir.Decimal.new(1) => {Elixir.Decimal.from_float(1.0), nil, "1.0"},
      Elixir.Decimal.from_float(1.2e3) => {Elixir.Decimal.new("1200.0"), nil, "1200.0"},
      "1" => {Elixir.Decimal.from_float(1.0), "1", "1.0"},
      "01" => {Elixir.Decimal.from_float(1.0), "01", "1.0"},
      "0123" => {Elixir.Decimal.from_float(123.0), "0123", "123.0"},
      "-1" => {Elixir.Decimal.from_float(-1.0), "-1", "-1.0"},
      "1." => {Elixir.Decimal.from_float(1.0), "1.", "1.0"},
      "1.0" => {Elixir.Decimal.from_float(1.0), nil, "1.0"},
      "1.000000000" => {Elixir.Decimal.from_float(1.0), "1.000000000", "1.0"},
      "+001.00" => {Elixir.Decimal.from_float(1.0), "+001.00", "1.0"},
      "123.456" => {Elixir.Decimal.from_float(123.456), nil, "123.456"},
      "0123.456" => {Elixir.Decimal.from_float(123.456), "0123.456", "123.456"},
      "010.020" => {Elixir.Decimal.from_float(10.02), "010.020", "10.02"},
      "2.3" => {Elixir.Decimal.from_float(2.3), nil, "2.3"},
      "2.345" => {Elixir.Decimal.from_float(2.345), nil, "2.345"},
      "2.234000005" => {Elixir.Decimal.from_float(2.234000005), nil, "2.234000005"},
      "1.234567890123456789012345789" =>
        {Elixir.Decimal.new("1.234567890123456789012345789"), nil,
         "1.234567890123456789012345789"},
      ".3" => {Elixir.Decimal.from_float(0.3), ".3", "0.3"},
      "-.3" => {Elixir.Decimal.from_float(-0.3), "-.3", "-0.3"}
    },
    invalid: [
      "foo",
      "10.1e1",
      "12.xyz",
      "3,5",
      "NaN",
      "Inf",
      true,
      false,
      "1.0 foo",
      "foo 1.0",
      Elixir.Decimal.new("NaN"),
      Elixir.Decimal.new("Inf")
    ]

  defmacrop sigil_d(str, _opts) do
    quote do
      Elixir.Decimal.new(unquote(str))
    end
  end

  test "Decimal.canonical_decimal/1" do
    assert Decimal.canonical_decimal(~d"0") == ~d"0.0"
    assert Decimal.canonical_decimal(~d"0.0") == ~d"0.0"
    assert Decimal.canonical_decimal(~d"0.001") == ~d"0.001"
    assert Decimal.canonical_decimal(~d"-0") == ~d"-0.0"
    assert Decimal.canonical_decimal(~d"-1") == ~d"-1.0"
    assert Decimal.canonical_decimal(~d"-0.00") == ~d"-0.0"
    assert Decimal.canonical_decimal(~d"1.00") == ~d"1.0"
    assert Decimal.canonical_decimal(~d"1000") == ~d"1000.0"
    assert Decimal.canonical_decimal(~d"1000.000000") == ~d"1000.0"
    assert Decimal.canonical_decimal(~d"12345.000") == ~d"12345.0"
    assert Decimal.canonical_decimal(~d"42") == ~d"42.0"
    assert Decimal.canonical_decimal(~d"42.42") == ~d"42.42"
    assert Decimal.canonical_decimal(~d"0.42") == ~d"0.42"
    assert Decimal.canonical_decimal(~d"0.0042") == ~d"0.0042"
    assert Decimal.canonical_decimal(~d"010.020") == ~d"10.02"
    assert Decimal.canonical_decimal(~d"-1.23") == ~d"-1.23"
    assert Decimal.canonical_decimal(~d"-0.0123") == ~d"-0.0123"
    assert Decimal.canonical_decimal(~d"1E+2") == ~d"100.0"
    assert Decimal.canonical_decimal(~d"1.2E3") == ~d"1200.0"
    assert Decimal.canonical_decimal(~d"-42E+3") == ~d"-42000.0"
  end
end
