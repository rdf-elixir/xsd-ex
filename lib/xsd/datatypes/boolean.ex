defmodule XSD.Boolean do
  @moduledoc """
  `XSD.Datatype` for XSD booleans.
  """

  use XSD.Datatype, id: "boolean"

  @impl XSD.Datatype
  def lexical_mapping(lexical) do
    with lexical do
      cond do
        lexical in ~W[true 1] -> true
        lexical in ~W[false 0] -> false
        true -> @invalid_value
      end
    end
  end

  @impl XSD.Datatype
  def elixir_mapping(value)
  def elixir_mapping(value) when is_boolean(value), do: value
  def elixir_mapping(1), do: true
  def elixir_mapping(0), do: false
  def elixir_mapping(_), do: @invalid_value
end
