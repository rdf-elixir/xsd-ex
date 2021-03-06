defmodule XSD.Date do
  @moduledoc """
  `XSD.Datatype` for XSD date.
  """

  @type valid_value :: Date.t() | {Date.t(), String.t()}

  use XSD.Datatype.Primitive, name: "date"

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
  @spec elixir_mapping(Date.t() | any, Keyword.t()) ::
          value | {value, XSD.Datatype.uncanonical_lexical()}
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
  @spec canonical_mapping(valid_value) :: String.t()
  def canonical_mapping(value)
  def canonical_mapping(%Date{} = value), do: Date.to_iso8601(value)
  def canonical_mapping({%Date{} = value, "+00:00"}), do: canonical_mapping(value) <> "Z"
  def canonical_mapping({%Date{} = value, zone}), do: canonical_mapping(value) <> zone

  @impl XSD.Datatype
  @spec init_valid_lexical(valid_value, XSD.Datatype.uncanonical_lexical(), Keyword.t()) ::
          XSD.Datatype.uncanonical_lexical()
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
  @spec init_invalid_lexical(any, Keyword.t()) :: String.t()
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
  def cast(literal_or_value)

  # Invalid values can not be casted in general
  def cast(%{value: @invalid_value}), do: nil

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

  def cast(literal_or_value), do: super(literal_or_value)

  @impl XSD.Datatype
  def equal_value?(literal1, literal2)

  def equal_value?(
        %__MODULE__{value: nil, uncanonical_lexical: lexical1},
        %__MODULE__{value: nil, uncanonical_lexical: lexical2}
      ) do
    lexical1 == lexical2
  end

  def equal_value?(%__MODULE__{value: value1}, %__MODULE__{value: value2})
      when is_nil(value1) or is_nil(value2),
      do: false

  def equal_value?(%__MODULE__{value: value1}, %__MODULE__{value: value2}) do
    XSD.DateTime.equal_value?(
      comparison_normalization(value1),
      comparison_normalization(value2)
    )
  end

  def equal_value?(%__MODULE__{}, %XSD.DateTime{}), do: false
  def equal_value?(%XSD.DateTime{}, %__MODULE__{}), do: false

  def equal_value?(left, right) do
    cond do
      is_nil(left) -> nil
      is_nil(right) -> nil
      not XSD.literal?(left) -> equal_value?(XSD.Literal.coerce(left), right)
      not XSD.literal?(right) -> equal_value?(left, XSD.Literal.coerce(right))
      true -> nil
    end
  end

  @impl XSD.Datatype
  def compare(left, right)

  def compare(
        %__MODULE__{value: value1},
        %__MODULE__{value: value2}
      )
      when is_nil(value1) or is_nil(value2),
      do: nil

  def compare(
        %__MODULE__{value: value1},
        %__MODULE__{value: value2}
      ) do
    XSD.DateTime.compare(
      comparison_normalization(value1),
      comparison_normalization(value2)
    )
  end

  # It seems quite strange that open-world test date-2 from the SPARQL 1.0 test suite
  #  allows for equality comparisons between dates and datetimes, but disallows
  #  ordering comparisons in the date-3 test. The following implementation would allow
  #  an ordering comparisons between date and datetimes.
  #
  #  def compare(
  #        %__MODULE__{value: date_value},
  #        %XSD.DateTime{} = datetime_literal
  #      ) do
  #    XSD.DateTime.compare(
  #      comparison_normalization(date_value),
  #      datetime_literal
  #    )
  #  end
  #
  #  def compare(
  #        %XSD.DateTime{} = datetime_literal,
  #        %__MODULE__{value: date_value}
  #      ) do
  #    XSD.DateTime.compare(
  #      datetime_literal,
  #      comparison_normalization(date_value)
  #    )
  #  end

  def compare(_, _), do: nil

  defp comparison_normalization({date, tz}) do
    (Date.to_iso8601(date) <> "T00:00:00" <> tz)
    |> XSD.DateTime.new()
  end

  defp comparison_normalization(%Date{} = date) do
    (Date.to_iso8601(date) <> "T00:00:00")
    |> XSD.DateTime.new()
  end

  defp comparison_normalization(_), do: nil
end
