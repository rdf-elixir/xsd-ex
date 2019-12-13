defmodule XSD.Boolean do
  @moduledoc """
  `XSD.Datatype` for XSD booleans.
  """

  use XSD.Datatype, id: "boolean"

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
