defmodule XSD.Boolean do
  @moduledoc """
  `XSD.Datatype` for XSD booleans.
  """

  use XSD.Datatype.Definition, name: "boolean"

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

  @impl XSD.Datatype
  def cast(literal)

  # Invalid values can not be casted in general
  def cast(%{value: @invalid_value}), do: @invalid_value

  def cast(%__MODULE__{} = xsd_boolean), do: xsd_boolean

  def cast(%XSD.String{} = xsd_string) do
    xsd_string.value
    |> new()
    |> canonical()
    |> validate_cast()
  end

  def cast(%XSD.Decimal{} = xsd_decimal) do
    !Decimal.equal?(xsd_decimal.value, 0) |> new()
  end

  def cast(literal) do
    if XSD.Numeric.literal?(literal) do
      new(literal.value not in [0, 0.0, :nan])
    else
      @invalid_value
    end
  end

  @doc """
  Returns an Effective Boolean Value (EBV).

  The Effective Boolean Value is an algorithm to coerce values to a `XSD.Boolean`.

  It is specified and used in the SPARQL query language and is based upon XPath's
  `fn:boolean`. Other than specified in these specs any value which can not be
  converted into a boolean results in `nil`.

  see
  - <https://www.w3.org/TR/xpath-31/#id-ebv>
  - <https://www.w3.org/TR/sparql11-query/#ebv>

  """
  def ebv(value)

  def ebv(true), do: XSD.Boolean.Value.true()
  def ebv(false), do: XSD.Boolean.Value.false()

  def ebv(%__MODULE__{value: nil}), do: XSD.Boolean.Value.false()
  def ebv(%__MODULE__{} = value), do: value

  def ebv(%XSD.String{} = string) do
    if String.length(string.value) == 0,
      do: XSD.Boolean.Value.false(),
      else: XSD.Boolean.Value.true()
  end

  def ebv(%datatype{} = literal) do
    if XSD.Numeric.datatype?(datatype) do
      if XSD.Literal.valid?(literal) and
           not (literal.value == 0 or literal.value == :nan),
         do: XSD.Boolean.Value.true(),
         else: XSD.Boolean.Value.false()
    end
  end

  def ebv(value) when is_binary(value) or is_number(value) do
    value |> XSD.Literal.coerce() |> ebv()
  end

  def ebv(_), do: nil

  @doc """
  Alias for `ebv/1`.
  """
  def effective(value), do: ebv(value)

  @doc """
  Returns `XSD.true` if the effective boolean value of the given argument is `XSD.false`, or `XSD.false` if it is `XSD.true`.

  Otherwise it returns `nil`.

  ## Examples

      iex> XSD.Boolean.fn_not(XSD.true)
      XSD.false
      iex> XSD.Boolean.fn_not(XSD.false)
      XSD.true

      iex> XSD.Boolean.fn_not(true)
      XSD.false
      iex> XSD.Boolean.fn_not(false)
      XSD.true

      iex> XSD.Boolean.fn_not(42)
      XSD.false
      iex> XSD.Boolean.fn_not("")
      XSD.true

      iex> XSD.Boolean.fn_not(nil)
      nil

  see <https://www.w3.org/TR/xpath-functions/#func-not>
  """
  def fn_not(value) do
    case ebv(value) do
      %__MODULE__{value: true} -> XSD.Boolean.Value.false()
      %__MODULE__{value: false} -> XSD.Boolean.Value.true()
      nil -> nil
    end
  end

  @doc """
  Returns the logical `AND` of the effective boolean value of the given arguments.

  It returns `nil` if only one argument is `nil` and the other argument is
  `XSD.true` and `XSD.false` if the other argument is `XSD.false`.

  ## Examples

      iex> XSD.Boolean.logical_and(XSD.true, XSD.true)
      XSD.true
      iex> XSD.Boolean.logical_and(XSD.true, XSD.false)
      XSD.false

      iex> XSD.Boolean.logical_and(XSD.true, nil)
      nil
      iex> XSD.Boolean.logical_and(nil, XSD.false)
      XSD.false
      iex> XSD.Boolean.logical_and(nil, nil)
      nil

  see <https://www.w3.org/TR/sparql11-query/#func-logical-and>

  """
  def logical_and(left, right) do
    case ebv(left) do
      %__MODULE__{value: false} ->
        XSD.Boolean.Value.false()

      %__MODULE__{value: true} ->
        case ebv(right) do
          %__MODULE__{value: true} -> XSD.Boolean.Value.true()
          %__MODULE__{value: false} -> XSD.Boolean.Value.false()
          nil -> nil
        end

      nil ->
        if match?(%__MODULE__{value: false}, ebv(right)) do
          XSD.Boolean.Value.false()
        end
    end
  end

  @doc """
  Returns the logical `OR` of the effective boolean value of the given arguments.

  It returns `nil` if only one argument is `nil` and the other argument is
  `XSD.false` and `XSD.true` if the other argument is `XSD.true`.

  ## Examples

      iex> XSD.Boolean.logical_or(XSD.true, XSD.false)
      XSD.true
      iex> XSD.Boolean.logical_or(XSD.false, XSD.false)
      XSD.false

      iex> XSD.Boolean.logical_or(XSD.true, nil)
      XSD.true
      iex> XSD.Boolean.logical_or(nil, XSD.false)
      nil
      iex> XSD.Boolean.logical_or(nil, nil)
      nil

  see <https://www.w3.org/TR/sparql11-query/#func-logical-or>

  """
  def logical_or(left, right) do
    case ebv(left) do
      %__MODULE__{value: true} ->
        XSD.Boolean.Value.true()

      %__MODULE__{value: false} ->
        case ebv(right) do
          %__MODULE__{value: true} -> XSD.Boolean.Value.true()
          %__MODULE__{value: false} -> XSD.Boolean.Value.false()
          nil -> nil
        end

      nil ->
        if match?(%__MODULE__{value: true}, ebv(right)) do
          XSD.Boolean.Value.true()
        end
    end
  end
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
