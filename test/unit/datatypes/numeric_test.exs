defmodule XSD.NumericTest do
  use ExUnit.Case
  #  use XSD.Test.Case

  alias XSD.Numeric

  @negative_zeros ~w[
    -0
    -000
    -0.0
    -0.00000
  ]

  test "negative_zero?/1" do
    Enum.each(@negative_zeros, fn negative_zero ->
      assert Numeric.negative_zero?(XSD.double(negative_zero))
      assert Numeric.negative_zero?(XSD.decimal(negative_zero))
    end)

    refute Numeric.negative_zero?(XSD.double("-0.00001"))
    refute Numeric.negative_zero?(XSD.decimal("-0.00001"))
  end

  test "zero?/1" do
    assert Numeric.zero?(XSD.integer(0))
    assert Numeric.zero?(XSD.integer("0"))

    ~w[
      0
      000
      0.0
      00.00
    ]
    |> Enum.each(fn positive_zero ->
      assert Numeric.zero?(XSD.double(positive_zero))
      assert Numeric.zero?(XSD.decimal(positive_zero))
    end)

    Enum.each(@negative_zeros, fn negative_zero ->
      assert Numeric.zero?(XSD.double(negative_zero))
      assert Numeric.zero?(XSD.decimal(negative_zero))
    end)

    refute Numeric.zero?(XSD.double("-0.00001"))
    refute Numeric.zero?(XSD.decimal("-0.00001"))
  end
end
