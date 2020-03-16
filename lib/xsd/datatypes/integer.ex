defmodule XSD.Integer do
  @moduledoc """
  `XSD.Datatype` for XSD integers.
  """

  use XSD.Datatype.Definition, name: "integer"

  @impl XSD.Datatype
  def lexical_mapping(lexical, _) do
    case Integer.parse(lexical) do
      {integer, ""} -> integer
      {_, _} -> @invalid_value
      :error -> @invalid_value
    end
  end

  @impl XSD.Datatype
  def elixir_mapping(value, _)
  def elixir_mapping(value, _) when is_integer(value), do: value
  def elixir_mapping(_, _), do: @invalid_value

  @impl XSD.Datatype
  def cast(literal)

  # Invalid values can not be casted in general
  def cast(%{value: @invalid_value}), do: @invalid_value

  def cast(%__MODULE__{} = xsd_integer), do: xsd_integer

  def cast(%XSD.Boolean{value: false}), do: new(0)
  def cast(%XSD.Boolean{value: true}), do: new(1)

  def cast(%XSD.String{} = xsd_string) do
    xsd_string.value
    |> new()
    |> canonical()
    |> validate_cast()
  end

  def cast(%XSD.Decimal{} = xsd_decimal) do
    xsd_decimal.value
    |> Decimal.round(0, :down)
    |> Decimal.to_integer()
    |> new()
  end

  def cast(%XSD.Double{value: value}) when is_float(value) do
    value
    |> trunc()
    |> new()
  end

  def cast(_), do: @invalid_value

  @impl XSD.Datatype
  def equal_value?(left, right), do: XSD.Numeric.equal_value?(left, right)

  @impl XSD.Datatype
  def compare(left, right), do: XSD.Numeric.compare(left, right)
end
