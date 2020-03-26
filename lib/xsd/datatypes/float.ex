defmodule XSD.Float do
  @moduledoc """
  `XSD.Datatype` for XSD floats.

  Although the XSD spec defines floats as a primitive we derive it here from `XSD.Double`
  with any further constraints, since Erlang doesn't support 32-bit floats.
  """

  use XSD.Datatype.Restriction,
    name: "float",
    base: XSD.Double
end
