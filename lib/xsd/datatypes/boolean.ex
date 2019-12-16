defmodule XSD.Boolean do
  @moduledoc """
  `XSD.Datatype` for XSD booleans.
  """

  use XSD.Datatype, name: "boolean"

  @impl XSD.Datatype
  def lexical_mapping(lexical, _) do
    with lexical do
      cond do
        lexical in ~W[true 1] -> true
        lexical in ~W[false 0] -> false
        true -> @invalid_value
      end
    end
  end

  @impl XSD.Datatype
  def elixir_mapping(value, _)
  def elixir_mapping(value, _) when is_boolean(value), do: value
  def elixir_mapping(1, _), do: true
  def elixir_mapping(0, _), do: false
  def elixir_mapping(_, _), do: @invalid_value

  @impl XSD.Datatype
  def cast(xsd_typed_value)

  # Invalid values can not be casted in general
  def cast(%{value: @invalid_value}), do: @invalid_value

  def cast(%__MODULE__{} = xsd_boolean), do: xsd_boolean

  def cast(%XSD.String{} = xsd_string) do
    xsd_string.value
    |> new()
    |> canonical()
    |> validate_cast()
  end

  def cast(%XSD.Decimal{} = xsd_decimal) do
    !Decimal.equal?(xsd_decimal.value, 0) |> new()
  end

  def cast(value) do
    if XSD.Numeric.value?(value) do
      new(value.value not in [0, 0.0, :nan])
    else
      @invalid_value
    end
  end
end

defmodule XSD.Boolean.Value do
  @moduledoc !"""
             This module holds the two `XSD.Boolean` values, so they can be accessed
             directly without needing to construct them every time. They can't
             be defined in the XSD.Boolean module, because we can not use the
             `XSD.Boolean.new` function without having it compiled first.
             """

  @xsd_true XSD.Boolean.new(true)
  @xsd_false XSD.Boolean.new(false)

  def unquote(true)(), do: @xsd_true
  def unquote(false)(), do: @xsd_false
end
