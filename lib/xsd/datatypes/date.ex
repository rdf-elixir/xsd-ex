defmodule XSD.Date do
  @moduledoc """
  `XSD.Datatype` for XSD date.
  """

  use XSD.Datatype, name: "date"

  @grammar ~r/\A(-?\d{4}-\d{2}-\d{2})((?:[\+\-]\d{2}:\d{2})|UTC|GMT|Z)?\Z/
  @tz_grammar ~r/\A((?:[\+\-]\d{2}:\d{2})|UTC|GMT|Z)\Z/

  @impl XSD.Datatype
  def lexical_mapping(lexical, opts) do
    case Regex.run(@grammar, lexical) do
      [_, date] -> do_lexical_mapping(date, opts)
      [_, date, tz] -> do_lexical_mapping(date, Keyword.put_new(opts, :tz, tz))
      _ -> @invalid_value
    end
  end

  defp do_lexical_mapping(value, opts) do
    case Date.from_iso8601(value) do
      {:ok, date} -> elixir_mapping(date, opts)
      _ -> @invalid_value
    end
    |> case do
      {{_, _} = value, _} -> value
      value -> value
    end
  end

  @impl XSD.Datatype
  def elixir_mapping(value, opts)

  # Special case for date and dateTime, for which 0 is not a valid year
  def elixir_mapping(%Date{year: 0}, _), do: @invalid_value

  def elixir_mapping(%Date{} = value, opts) do
    if tz = Keyword.get(opts, :tz) do
      if valid_timezone?(tz) do
        {{value, timezone_mapping(tz)}, nil}
      else
        @invalid_value
      end
    else
      value
    end
  end

  def elixir_mapping(_, _), do: @invalid_value

  defp valid_timezone?(string), do: Regex.match?(@tz_grammar, string)

  defp timezone_mapping("+00:00"), do: "Z"
  defp timezone_mapping(tz), do: tz

  @impl XSD.Datatype
  def canonical_mapping(value)
  def canonical_mapping(%Date{} = value), do: Date.to_iso8601(value)
  def canonical_mapping({%Date{} = value, "+00:00"}), do: canonical_mapping(value) <> "Z"
  def canonical_mapping({%Date{} = value, zone}), do: canonical_mapping(value) <> zone

  @impl XSD.Datatype
  def init_valid_lexical(value, lexical, opts)

  def init_valid_lexical({value, _}, nil, opts) do
    if tz = Keyword.get(opts, :tz) do
      canonical_mapping(value) <> tz
    else
      nil
    end
  end

  def init_valid_lexical(_, nil, _), do: nil

  def init_valid_lexical(_, lexical, opts) do
    if tz = Keyword.get(opts, :tz) do
      # When using the :tz option, we'll have to strip off the original timezone
      case Regex.run(@grammar, lexical) do
        [_, date] -> date
        [_, date, _] -> date
      end <> tz
    else
      lexical
    end
  end

  @impl XSD.Datatype
  def init_invalid_lexical(value, opts)

  def init_invalid_lexical({date, tz}, opts) do
    if tz_opt = Keyword.get(opts, :tz) do
      to_string(date) <> tz_opt
    else
      to_string(date) <> to_string(tz)
    end
  end

  def init_invalid_lexical(value, _) when is_binary(value), do: value

  def init_invalid_lexical(value, opts) do
    if tz = Keyword.get(opts, :tz) do
      to_string(value) <> tz
    else
      to_string(value)
    end
  end

  @impl XSD.Datatype
  def cast(xsd_typed_value)

  # Invalid values can not be casted in general
  def cast(%{value: @invalid_value}), do: @invalid_value

  def cast(%__MODULE__{} = xsd_date), do: xsd_date

  def cast(%XSD.DateTime{} = xsd_datetime) do
    case xsd_datetime.value do
      %NaiveDateTime{} = datetime ->
        datetime
        |> NaiveDateTime.to_date()
        |> new()

      %DateTime{} = datetime ->
        datetime
        |> DateTime.to_date()
        |> new(tz: XSD.DateTime.tz(xsd_datetime))
    end
  end

  def cast(%XSD.String{} = xsd_string), do: new(xsd_string.value)

  def cast(_), do: @invalid_value
end
