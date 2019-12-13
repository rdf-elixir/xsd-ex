defmodule XSD do
  @moduledoc """
  TODO: Documentation for XSD.
  """

  defdelegate unquote(true)(), to: XSD.Boolean.Value
  defdelegate unquote(false)(), to: XSD.Boolean.Value
end
