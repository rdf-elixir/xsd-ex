defmodule XSD.String do
  @moduledoc """
  `XSD.Datatype` for XSD strings.
  """

  use XSD.Datatype.Definition, name: "string"

  @impl XSD.Datatype
  def lexical_mapping(lexical, _), do: to_string(lexical)

  @impl XSD.Datatype
  def elixir_mapping(value, _), do: to_string(value)

  @impl XSD.Datatype
  def cast(xsd_typed_value)

  # Invalid values can not be casted in general
  def cast(%{value: @invalid_value}), do: @invalid_value

  def cast(%__MODULE__{} = xsd_string), do: xsd_string

  def cast(%XSD.Decimal{} = xsd_decimal) do
    try do
      xsd_decimal.value
      |> Decimal.to_integer()
      |> XSD.Integer.new()
      |> cast()
    rescue
      _ ->
        default_canonical_cast(xsd_decimal, XSD.Decimal)
    end
  end

  def cast(%XSD.Double{} = xsd_double) do
    cond do
      XSD.Numeric.negative_zero?(xsd_double) ->
        new("-0")

      XSD.Numeric.zero?(xsd_double) ->
        new("0")

      xsd_double.value >= 0.000_001 and xsd_double.value < 1_000_000 ->
        xsd_double.value
        |> XSD.Decimal.new()
        |> cast()

      true ->
        default_canonical_cast(xsd_double, XSD.Double)
    end
  end

  def cast(%XSD.DateTime{} = xsd_datetime) do
    xsd_datetime
    |> XSD.DateTime.canonical_lexical_with_zone()
    |> new()
  end

  def cast(%XSD.Time{} = xsd_time) do
    xsd_time
    |> XSD.Time.canonical_lexical_with_zone()
    |> new()
  end

  def cast(%datatype{} = value) do
    if XSD.datatype?(datatype) do
      default_canonical_cast(value, datatype)
    else
      @invalid_value
    end
  end

  def cast(_), do: @invalid_value

  defp default_canonical_cast(value, datatype) do
    value
    |> datatype.canonical_lexical()
    |> new()
  end
end
