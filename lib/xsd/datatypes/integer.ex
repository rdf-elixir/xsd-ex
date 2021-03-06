defmodule XSD.Integer do
  @moduledoc """
  `XSD.Datatype` for XSD integers.

  Although the XSD spec defines integers as derived from `xsd:decimal` we implement
  it here as a primitive datatype for simplicity and performance reasons.
  """

  @type valid_value :: integer

  use XSD.Datatype.Primitive, name: "integer"

  def_applicable_facet XSD.Facets.MinInclusive
  def_applicable_facet XSD.Facets.MaxInclusive

  def min_inclusive_conform?(min_inclusive, value, _lexical) do
    value >= min_inclusive
  end

  def max_inclusive_conform?(max_inclusive, value, _lexical) do
    value <= max_inclusive
  end

  @impl XSD.Datatype
  def lexical_mapping(lexical, _) do
    case Integer.parse(lexical) do
      {integer, ""} -> integer
      {_, _} -> @invalid_value
      :error -> @invalid_value
    end
  end

  @impl XSD.Datatype
  @spec elixir_mapping(valid_value | any, Keyword.t()) :: value
  def elixir_mapping(value, _)
  def elixir_mapping(value, _) when is_integer(value), do: value
  def elixir_mapping(_, _), do: @invalid_value

  @impl XSD.Datatype
  def cast(literal_or_value)

  # Invalid values can not be casted in general
  def cast(%{value: @invalid_value}), do: nil

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

  def cast(%datatype{value: value})
      when datatype in [XSD.Double, XSD.Float] and is_float(value) do
    value
    |> trunc()
    |> new()
  end

  def cast(literal_or_value), do: super(literal_or_value)

  @impl XSD.Datatype
  def equal_value?(left, right), do: XSD.Numeric.equal_value?(left, right)

  @impl XSD.Datatype
  def compare(left, right), do: XSD.Numeric.compare(left, right)

  @doc """
  The number of digits in the XML Schema canonical form of the literal value.
  """
  @spec digit_count(XSD.Literal.t()) :: non_neg_integer | nil
  def digit_count(%datatype{} = literal) do
    if derived?(literal) and datatype.valid?(literal) do
      literal
      |> datatype.canonical()
      |> datatype.lexical()
      |> String.replace("-", "")
      |> String.length()
    end
  end
end
