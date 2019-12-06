defmodule XSD.String do
  @moduledoc """
  `XSD.Datatype` for XSD strings.
  """

  use XSD.Datatype, id: "string"

  @impl XSD.Datatype
  def lexical_mapping(lexical), do: to_string(lexical)

  @impl XSD.Datatype
  def elixir_mapping(value), do: to_string(value)
end
