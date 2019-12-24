defmodule XSD.DateTime do
  @moduledoc """
  `XSD.Datatype` for XSD dateTimes.
  """

  use XSD.Datatype, name: "dateTime"

  @impl XSD.Datatype
  def lexical_mapping(lexical, opts) do
    case DateTime.from_iso8601(lexical) do
      {:ok, datetime, _} ->
        elixir_mapping(datetime, opts)

      {:error, :missing_offset} ->
        case NaiveDateTime.from_iso8601(lexical) do
          {:ok, datetime} -> elixir_mapping(datetime, opts)
          _ -> @invalid_value
        end

      {:error, :invalid_format} ->
        if String.ends_with?(lexical, "-00:00") do
          lexical
          |> String.replace_trailing("-00:00", "Z")
          |> lexical_mapping(opts)
        else
          @invalid_value
        end

      {:error, :invalid_time} ->
        if String.contains?(lexical, "T24:00:00") do
          with [day, tz] <- String.split(lexical, "T24:00:00", parts: 2),
               {:ok, day} <- Date.from_iso8601(day) do
            lexical_mapping("#{day |> Date.add(1) |> Date.to_string()}T00:00:00#{tz}", opts)
          else
            _ -> @invalid_value
          end
        else
          @invalid_value
        end

      _ ->
        @invalid_value
    end
  end

  @impl XSD.Datatype
  def elixir_mapping(value, _)
  # Special case for date and dateTime, for which 0 is not a valid year
  def elixir_mapping(%DateTime{year: 0}, _), do: @invalid_value
  def elixir_mapping(%DateTime{} = value, _), do: value
  # Special case for date and dateTime, for which 0 is not a valid year
  def elixir_mapping(%NaiveDateTime{year: 0}, _), do: @invalid_value
  def elixir_mapping(%NaiveDateTime{} = value, _), do: value
  def elixir_mapping(_, _), do: @invalid_value

  @impl XSD.Datatype
  def canonical_mapping(value)
  def canonical_mapping(%DateTime{} = value), do: DateTime.to_iso8601(value)
  def canonical_mapping(%NaiveDateTime{} = value), do: NaiveDateTime.to_iso8601(value)

  @impl XSD.Datatype
  def cast(xsd_typed_value)

  # Invalid values can not be casted in general
  def cast(%{value: @invalid_value}), do: @invalid_value

  def cast(%__MODULE__{} = xsd_datetime), do: xsd_datetime

  def cast(%XSD.Date{} = xsd_date) do
    case xsd_date.value do
      {value, zone} ->
        (value |> XSD.Date.new() |> XSD.Date.canonical_lexical()) <> "T00:00:00" <> zone

      value ->
        (value |> XSD.Date.new() |> XSD.Date.canonical_lexical()) <> "T00:00:00"
    end
    |> new()
  end

  def cast(%XSD.String{} = xsd_string) do
    xsd_string.value
    |> new()
    |> validate_cast()
  end

  def cast(_), do: @invalid_value

  @doc """
  Extracts the timezone string from a `XSD.DateTime` value.
  """
  def tz(xsd_datetime)

  def tz(%__MODULE__{value: %NaiveDateTime{}}), do: ""

  def tz(date_time_literal) do
    if valid?(date_time_literal) do
      date_time_literal
      |> lexical()
      |> XSD.Utils.DateTime.tz()
    end
  end

  @doc """
  Converts a datetime literal to a canonical string, preserving the zone information.
  """
  def canonical_lexical_with_zone(%__MODULE__{} = xsd_datetime) do
    case tz(xsd_datetime) do
      nil ->
        nil

      zone when zone in ["Z", "", "+00:00", "-00:00"] ->
        canonical_lexical(xsd_datetime)

      zone ->
        xsd_datetime
        |> lexical()
        |> String.replace_trailing(zone, "Z")
        |> DateTime.from_iso8601()
        |> elem(1)
        |> new()
        |> canonical_lexical()
        |> String.replace_trailing("Z", zone)
    end
  end

  @impl XSD.Datatype
  def equal_value?(left, right)

  def equal_value?(
        %__MODULE__{value: %type{} = value1},
        %__MODULE__{value: %type{} = value2}
      ) do
    type.compare(value1, value2) == :eq
  end

  def equal_value?(
        %__MODULE__{value: nil, uncanonical_lexical: lexical1},
        %__MODULE__{value: nil, uncanonical_lexical: lexical2}
      ) do
    lexical1 == lexical2
  end

  def equal_value?(_, _), do: false
end
