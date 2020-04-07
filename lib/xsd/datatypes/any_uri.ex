defmodule XSD.AnyURI do
  @moduledoc """
  `XSD.Datatype` for XSD anyURIs.

  See: <http://www.w3.org/TR/xmlschema11-2/#anyURI>
  """

  @type valid_value :: URI.t()

  use XSD.Datatype.Primitive, name: "anyURI"

  @impl XSD.Datatype
  @spec lexical_mapping(String.t(), Keyword.t()) :: valid_value
  def lexical_mapping(lexical, _), do: URI.parse(lexical)

  @impl XSD.Datatype
  @spec elixir_mapping(any, Keyword.t()) :: value
  def elixir_mapping(%URI{} = uri, _), do: uri
  def elixir_mapping(_, _), do: @invalid_value
end
