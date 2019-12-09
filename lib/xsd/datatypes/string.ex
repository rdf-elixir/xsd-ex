defmodule XSD.String do
  @moduledoc """
  `XSD.Datatype` for XSD strings.
  """

  use XSD.Datatype, id: "string"

  @impl XSD.Datatype
  def lexical_mapping(lexical, _), do: to_string(lexical)

  @impl XSD.Datatype
  def elixir_mapping(value, _), do: to_string(value)
end
