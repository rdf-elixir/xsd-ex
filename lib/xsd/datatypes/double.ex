defmodule XSD.Double do
  @moduledoc """
  `XSD.Datatype` for XSD doubles.
  """

  use XSD.Datatype, name: "double"

  @special_values ~W[positive_infinity negative_infinity nan]a

  @impl XSD.Datatype
  def lexical_mapping(lexical, opts) do
    case Float.parse(lexical) do
      {float, ""} ->
        float

      {float, remainder} ->
        # 1.E-8 is not a valid Elixir float literal and consequently not fully parsed with Float.parse
        if Regex.match?(~r/^\.e?[\+\-]?\d+$/i, remainder) do
          lexical_mapping(to_string(float) <> String.trim_leading(remainder, "."), opts)
        else
          @invalid_value
        end

      :error ->
        case String.upcase(lexical) do
          "INF" -> :positive_infinity
          "-INF" -> :negative_infinity
          "NAN" -> :nan
          _ -> @invalid_value
        end
    end
  end

  @impl XSD.Datatype
  def elixir_mapping(value, _)
  def elixir_mapping(value, _) when is_float(value), do: value
  def elixir_mapping(value, _) when is_integer(value), do: value / 1
  def elixir_mapping(value, _) when value in @special_values, do: value
  def elixir_mapping(_, _), do: @invalid_value

  @impl XSD.Datatype
  def init_valid_lexical(value, lexical, opts)
  def init_valid_lexical(value, nil, _) when is_atom(value), do: nil
  def init_valid_lexical(value, nil, _), do: decimal_form(value)
  def init_valid_lexical(_, lexical, _), do: lexical

  defp decimal_form(float), do: to_string(float)

  @impl XSD.Datatype
  def canonical_mapping(value)

  # Produces the exponential form of a float
  def canonical_mapping(float) when is_float(float) do
    # We can't use simple %f transformation due to special requirements from N3 tests in representation
    [i, f, e] =
      float
      |> float_to_string()
      |> String.split(~r/[\.e]/)

    # remove any trailing zeroes
    f =
      case String.replace(f, ~r/0*$/, "", global: false) do
        # ...but there must be a digit to the right of the decimal point
        "" -> "0"
        f -> f
      end

    e = String.trim_leading(e, "+")

    "#{i}.#{f}E#{e}"
  end

  def canonical_mapping(:nan), do: "NaN"
  def canonical_mapping(:positive_infinity), do: "INF"
  def canonical_mapping(:negative_infinity), do: "-INF"

  if List.to_integer(:erlang.system_info(:otp_release)) >= 21 do
    defp float_to_string(float) do
      :io_lib.format("~.15e", [float])
      |> to_string()
    end
  else
    defp float_to_string(float) do
      :io_lib.format("~.15e", [float])
      |> List.first()
      |> to_string()
    end
  end

  @impl XSD.Datatype
  def cast(xsd_typed_value)

  # Invalid values can not be casted in general
  def cast(%{value: @invalid_value}), do: @invalid_value

  def cast(%__MODULE__{} = xsd_double), do: xsd_double

  def cast(%XSD.Boolean{value: false}), do: new(0.0)
  def cast(%XSD.Boolean{value: true}), do: new(1.0)

  def cast(%XSD.String{} = xsd_string) do
    xsd_string.value
    |> new()
    |> canonical()
    |> validate_cast()
  end

  def cast(%XSD.Integer{} = xsd_integer) do
    new(xsd_integer.value)
  end

  def cast(%XSD.Decimal{} = xsd_decimal) do
    xsd_decimal.value
    |> Decimal.to_float()
    |> new()
  end

  def cast(_), do: @invalid_value

  @impl XSD.Datatype
  def equal_value?(left, right), do: XSD.Numeric.equal_value?(left, right)

  @impl XSD.Datatype
  def compare(left, right), do: XSD.Numeric.compare(left, right)
end
