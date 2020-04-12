defmodule XSD do
  @moduledoc """
  TODO: Documentation for XSD.
  """

  @xsd_namespace "http://www.w3.org/2001/XMLSchema#"

  @doc """
  Returns to official XSD namespace IRI.

  `"#{@xsd_namespace}"`
  """
  @spec namespace() :: String.t()
  def namespace(), do: @xsd_namespace

  @datatypes [
               XSD.Boolean,
               XSD.String,
               XSD.Date,
               XSD.Time,
               XSD.DateTime,
               XSD.AnyURI
             ]
             |> MapSet.new()
             |> MapSet.union(MapSet.new(XSD.Numeric.datatypes()))

  @datatypes_by_name Map.new(@datatypes, fn datatype -> {datatype.name(), datatype} end)
  @datatypes_by_iri Map.new(@datatypes, fn datatype -> {datatype.id(), datatype} end)

  @doc """
  The list of all XSD datatypes.
  """
  @spec datatypes() :: [XSD.Datatype.t()]
  def datatypes(), do: Enum.to_list(@datatypes)

  def datatype_by_name(name), do: @datatypes_by_name[name]
  def datatype_by_iri(iri), do: @datatypes_by_iri[iri]

  @doc """
  Returns if a given datatype is a XSD datatype.
  """
  def datatype?(datatype), do: datatype in @datatypes

  @doc """
  Returns if a given argument is a `XSD.datatype` literal.
  """
  def literal?(%datatype{}), do: datatype?(datatype)
  def literal?(_), do: false

  defdelegate equal?(left, right), to: XSD.Literal
  defdelegate equal_value?(left, right), to: XSD.Literal

  Enum.each(@datatypes, fn datatype ->
    defdelegate unquote(String.to_atom(datatype.name))(value), to: datatype, as: :new
    defdelegate unquote(String.to_atom(datatype.name))(value, opts), to: datatype, as: :new

    elixir_name = Macro.underscore(datatype.name)

    unless datatype.name == elixir_name do
      defdelegate unquote(String.to_atom(elixir_name))(value), to: datatype, as: :new
      defdelegate unquote(String.to_atom(elixir_name))(value, opts), to: datatype, as: :new
    end
  end)

  defdelegate datetime(value), to: XSD.DateTime, as: :new
  defdelegate datetime(value, opts), to: XSD.DateTime, as: :new

  defdelegate unquote(true)(), to: XSD.Boolean.Value
  defdelegate unquote(false)(), to: XSD.Boolean.Value
end
