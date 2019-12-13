defmodule XSD.Decimal do
  @moduledoc """
  `XSD.Datatype` for XSD decimals.
  """

  use XSD.Datatype, id: "decimal"

  alias Elixir.Decimal, as: D

  @impl XSD.Datatype
  def lexical_mapping(lexical, opts) do
    if String.contains?(lexical, ~w[e E]) do
      @invalid_value
    else
      case D.parse(lexical) do
        {:ok, decimal} -> elixir_mapping(decimal, opts)
        :error -> @invalid_value
      end
    end
  end

  @impl XSD.Datatype
  def elixir_mapping(value, _)

  def elixir_mapping(%D{coef: coef}, _) when coef in ~w[qNaN sNaN inf]a,
    do: @invalid_value

  def elixir_mapping(%D{} = decimal, _),
    do: canonical_decimal(decimal)

  def elixir_mapping(value, opts) when is_integer(value),
    do: value |> D.new() |> elixir_mapping(opts)

  def elixir_mapping(value, opts) when is_float(value),
    do: value |> D.from_float() |> elixir_mapping(opts)

  def elixir_mapping(_, _), do: @invalid_value

  @doc false
  def canonical_decimal(decimal)

  def canonical_decimal(%D{coef: 0} = decimal),
    do: %{decimal | exp: -1}

  def canonical_decimal(%D{coef: coef, exp: 0} = decimal),
    do: %{decimal | coef: coef * 10, exp: -1}

  def canonical_decimal(%D{coef: coef, exp: exp} = decimal)
      when exp > 0,
      do: canonical_decimal(%{decimal | coef: coef * 10, exp: exp - 1})

  def canonical_decimal(%D{coef: coef} = decimal)
      when Kernel.rem(coef, 10) != 0,
      do: decimal

  def canonical_decimal(%D{coef: coef, exp: exp} = decimal),
    do: canonical_decimal(%{decimal | coef: Kernel.div(coef, 10), exp: exp + 1})

  @impl XSD.Datatype
  def canonical_mapping(value)

  def canonical_mapping(%D{sign: sign, coef: :qNaN}),
    do: if(sign == 1, do: "NaN", else: "-NaN")

  def canonical_mapping(%D{sign: sign, coef: :sNaN}),
    do: if(sign == 1, do: "sNaN", else: "-sNaN")

  def canonical_mapping(%D{sign: sign, coef: :inf}),
    do: if(sign == 1, do: "Infinity", else: "-Infinity")

  def canonical_mapping(%D{} = decimal),
    do: D.to_string(decimal, :normal)
end
