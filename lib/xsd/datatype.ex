defmodule XSD.Datatype do
  @moduledoc """
  A behaviour for the definition of XSD datatypes.
  """

  @ns "http://www.w3.org/2001/XMLSchema#"

  @doc """
  Returns to official XSD namespace IRI.

  `"#{@ns}"`
  """
  def ns(), do: @ns

  def iri(datatype), do: @ns <> datatype

  @doc """
  The name of the datatype.
  """
  @callback name :: String.t()

  @doc """
  The IRI of the datatype.
  """
  @callback id :: String.t()

  @doc """
  Determines if the lexical form of a `XSD.Datatype` is a member of its lexical value space.
  """
  @callback valid?(any) :: boolean

  @doc """
  Returns the lexical form of a `XSD.Datatype` value.
  """
  @callback lexical(any) :: String.t()

  @doc """
  Produces the canonical representation of a `XSD.Datatype` value.
  """
  @callback canonical(any) :: any

  @doc """
  Casts a `XSD.Datatype` value of one type into a `XSD.Datatype` value of another type.

  If the given value is invalid or can not be converted into this datatype an
  implementation should return `@invalid_value`.
  """
  @callback cast(any) :: any

  @doc """
  Checks if two value `XSD.Datatype` values are equal.

  The default implementation of the `_using__` macro compares the values of the
  `canonical/1` forms of the given value of this datatype.
  """
  @callback equal_value?(value1 :: any, value2 :: any) :: boolean

  @doc """
  Compares two `XSD.Datatype` values.

  Returns `:gt` if first value is greater than the second in terms of their datatype
  and `:lt` for vice versa. If the two values are equal `:eq` is returned.
  For datatypes with only partial ordering `:indeterminate` is returned when the
  order of the given literals is not defined.

  Returns `nil` when the given arguments are not comparable datatypes or if one
  them is invalid.

  The default implementation of the `_using__` macro compares the values of the
  `canonical/1` forms of the given values of this datatype.
  """
  @callback compare(value1 :: any, value2 :: any) :: :lt | :gt | :eq | :indeterminate | nil

  @doc """
  A mapping from the lexical space of a `XSD.Datatype` into its value space.
  """
  @callback lexical_mapping(String.t(), Keyword.t()) :: any

  @doc """
  A mapping from Elixir values into the value space of a `XSD.Datatype`.
  """
  @callback elixir_mapping(any, Keyword.t()) :: any

  @doc """
  Returns the standard lexical representation for a value of the value space of a `XSD.Datatype`.
  """
  @callback canonical_mapping(any) :: String.t()

  @doc """
  Returns the lexical representation to be used as for a `XSD.Datatype`.

  If the lexical representation for a given `value` and `lexical` should be the
  canonical one, an implementation should return `nil`.
  """
  @callback init_valid_lexical(any, String.t(), Keyword.t()) :: String.t()

  @doc """
  Produces the lexical representation of an invalid value.

  The default implementation of the `_using__` macro just returns `to_string/1`
  representation of the value.
  """
  @callback init_invalid_lexical(any, Keyword.t()) :: String.t()
end
