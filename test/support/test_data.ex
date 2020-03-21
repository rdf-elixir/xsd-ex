defmodule XSD.TestData do
  @valid_positive_integer %{
    # input => { value, lexical, canonicalized }
    1 => {1, nil, "1"},
    "1" => {1, nil, "1"},
    "01" => {1, "01", "1"},
    "0123" => {123, "0123", "123"},
    +1 => {1, nil, "1"},
    "+1" => {1, "+1", "1"}
  }

  @valid_non_negative_integer %{
                                0 => {0, nil, "0"},
                                "0" => {0, nil, "0"}
                              }
                              |> Map.merge(@valid_positive_integer)

  @valid_integer %{
                   -1 => {-1, nil, "-1"},
                   "-1" => {-1, nil, "-1"}
                 }
                 |> Map.merge(@valid_non_negative_integer)

  @invalid_integer [
    "foo",
    "10.1",
    "12xyz",
    true,
    false,
    3.14,
    "1 2",
    "foo 1",
    "1 foo"
  ]

  @invalid_non_negative_integer [-1, "-1"] ++ @invalid_integer

  @invalid_positive_integer [0, "0"] ++ @invalid_non_negative_integer

  def valid_integer, do: @valid_integer
  def valid_non_negative_integer, do: @valid_non_negative_integer
  def valid_positive_integer, do: @valid_positive_integer

  def invalid_integer, do: @invalid_integer
  def invalid_non_negative_integer, do: @invalid_non_negative_integer
  def invalid_positive_integer, do: @invalid_positive_integer
end
