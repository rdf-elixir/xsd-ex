defmodule XSD.Integer do
  @moduledoc """
  `XSD.Datatype` for XSD integers.
  """

  use XSD.Datatype, name: "integer"

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
end
