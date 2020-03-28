defmodule XSD.Datatype.PrimitiveTest do
  use ExUnit.Case

  test "default_namespace/0" do
    assert XSD.Datatype.Primitive.default_namespace() == XSD.namespace()
  end
end
