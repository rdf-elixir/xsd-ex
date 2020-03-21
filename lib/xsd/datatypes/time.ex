defmodule XSD.Time do
  @moduledoc """
  `XSD.Datatype` for XSD times.
  """

  @type valid_value :: Time.t() | {Time.t(), true}

  use XSD.Datatype.Primitive, name: "time"

  @grammar ~r/\A(\d{2}:\d{2}:\d{2}(?:\.\d+)?)((?:[\+\-]\d{2}:\d{2})|UTC|GMT|Z)?\Z/
  @tz_number_grammar ~r/\A(?:([\+\-])(\d{2}):(\d{2}))\Z/

  @impl XSD.Datatype
  def lexical_mapping(lexical, opts) do
    case Regex.run(@grammar, lexical) do
      [_, time] ->
        do_lexical_mapping(time, opts)

      [_, time, tz] ->
        do_lexical_mapping(
          time,
          opts |> Keyword.put_new(:tz, tz) |> Keyword.put_new(:lexical_present, true)
        )

      _ ->
        @invalid_value
    end
  end

  defp do_lexical_mapping(value, opts) do
    case Time.from_iso8601(value) do
      {:ok, time} -> elixir_mapping(time, opts)
      _ -> @invalid_value
    end
    |> case do
      {{_, true} = value, _} -> value
      value -> value
    end
  end

  @impl XSD.Datatype
  @spec elixir_mapping(valid_value | any, Keyword.t()) ::
          value | {value, XSD.Datatype.uncanonical_lexical()}
  def elixir_mapping(value, opts)

  def elixir_mapping(%Time{} = value, opts) do
    if tz = Keyword.get(opts, :tz) do
      case with_offset(value, tz) do
        @invalid_value ->
          @invalid_value

        time ->
          {{time, true}, unless(Keyword.get(opts, :lexical_present), do: Time.to_iso8601(value))}
      end
    else
      value
    end
  end

  def elixir_mapping(_, _), do: @invalid_value

  defp with_offset(time, zone) when zone in ~W[Z UTC GMT], do: time

  defp with_offset(time, offset) do
    case Regex.run(@tz_number_grammar, offset) do
      [_, "-", hour, minute] ->
        {hour, minute} = {String.to_integer(hour), String.to_integer(minute)}
        minute = time.minute + minute
        {rem(time.hour + hour + div(minute, 60), 24), rem(minute, 60)}

      [_, "+", hour, minute] ->
        {hour, minute} = {String.to_integer(hour), String.to_integer(minute)}

        if (minute = time.minute - minute) < 0 do
          {rem(24 + time.hour - hour - 1, 24), minute + 60}
        else
          {rem(24 + time.hour - hour - div(minute, 60), 24), rem(minute, 60)}
        end

      nil ->
        @invalid_value
    end
    |> case do
      {hour, minute} -> %Time{time | hour: hour, minute: minute}
      @invalid_value -> @invalid_value
    end
  end

  @impl XSD.Datatype
  @spec canonical_mapping(valid_value) :: String.t()
  def canonical_mapping(value)
  def canonical_mapping(%Time{} = value), do: Time.to_iso8601(value)
  def canonical_mapping({%Time{} = value, true}), do: canonical_mapping(value) <> "Z"

  @impl XSD.Datatype
  @spec init_valid_lexical(valid_value, XSD.Datatype.uncanonical_lexical(), Keyword.t()) ::
          XSD.Datatype.uncanonical_lexical()
  def init_valid_lexical(value, lexical, opts)

  def init_valid_lexical({value, _}, nil, opts) do
    if tz = Keyword.get(opts, :tz) do
      canonical_mapping(value) <> tz
    end
  end

  def init_valid_lexical(_, nil, _), do: nil

  def init_valid_lexical(_, lexical, opts) do
    if tz = Keyword.get(opts, :tz) do
      # When using the :tz option, we'll have to strip off the original timezone
      case Regex.run(@grammar, lexical) do
        [_, time] -> time
        [_, time, _] -> time
      end <> tz
    else
      lexical
    end
  end

  @impl XSD.Datatype
  @spec init_invalid_lexical(any, Keyword.t()) :: String.t()
  def init_invalid_lexical(value, opts)

  def init_invalid_lexical({time, tz}, opts) do
    if tz_opt = Keyword.get(opts, :tz) do
      to_string(time) <> tz_opt
    else
      to_string(time) <> to_string(tz)
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
  def cast(literal_or_value)

  # Invalid values can not be casted in general
  def cast(%{value: @invalid_value}), do: nil

  def cast(%__MODULE__{} = xsd_date), do: xsd_date

  def cast(%XSD.DateTime{} = xsd_datetime) do
    case xsd_datetime.value do
      %NaiveDateTime{} = datetime ->
        datetime
        |> NaiveDateTime.to_time()
        |> new()

      %DateTime{} ->
        [_date, time_with_zone] =
          xsd_datetime
          |> XSD.DateTime.canonical_lexical_with_zone()
          |> String.split("T", parts: 2)

        new(time_with_zone)
    end
  end

  def cast(%XSD.String{} = xsd_string), do: new(xsd_string.value)

  def cast(literal_or_value), do: super(literal_or_value)

  @doc """
  Extracts the timezone string from a `XSD.Time` value.
  """
  def tz(time_literal) do
    if valid?(time_literal) do
      time_literal
      |> lexical()
      |> XSD.Utils.DateTime.tz()
    end
  end

  @doc """
  Converts a time literal to a canonical string, preserving the zone information.
  """
  def canonical_lexical_with_zone(%__MODULE__{} = xsd_time) do
    case tz(xsd_time) do
      nil ->
        nil

      zone when zone in ["Z", "", "+00:00"] ->
        canonical_lexical(xsd_time)

      zone ->
        xsd_time
        |> lexical()
        |> String.replace_trailing(zone, "")
        |> Time.from_iso8601!()
        |> new()
        |> canonical_lexical()
        |> Kernel.<>(zone)
    end
  end
end
