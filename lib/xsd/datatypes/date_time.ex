defmodule XSD.DateTime do
  @moduledoc """
  `XSD.Datatype` for XSD dateTimes.
  """

  use XSD.Datatype, id: "dateTime"

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
end
