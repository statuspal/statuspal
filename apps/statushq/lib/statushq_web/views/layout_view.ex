defmodule StatushqWeb.LayoutView do
  use StatushqWeb, :view

  def format_date conn, date, format, append_timezone \\ false do
    erl_date = NaiveDateTime.to_erl(date)
    # date = Timex.DateTime.from(erl_date)
    tzone = conn.assigns.status_page.time_zone
    {:ok, date} = Timex.format(Timex.Timezone.convert(date, tzone), format, :strftime)

    tz_abbrv = if append_timezone do
      tzone
      |> Tzdata.periods_for_time(:calendar.datetime_to_gregorian_seconds(erl_date), :wall)
      |> hd
      |> Map.get(:zone_abbr)
    else
      nil
    end

    date <> if(tz_abbrv, do: " #{tz_abbrv}", else: "")
  end

  def format_date conn, date do
    format_date(conn, date, "%B %eth, %Y at %H:%M", true)
  end

  def format_date_short conn, date do
    format_date(conn, date, "%b %eth, %Y %H:%M", true)
  end

  def format_date_time_shorter conn, date do
    format_date(conn, date, "%m/%d/%Y %H:%M")
  end

  def format_date_shorter conn, date do
    format_date(conn, date, "%m/%d/%Y")
  end

  def pluralize word, n do
    if n > 1, do: "#{word}s", else: word
  end

  def time_zones do
    now_secs = :calendar.datetime_to_gregorian_seconds(:calendar.universal_time)

    Tzdata.canonical_zone_list
    |> Enum.filter(fn(tz) -> !String.contains?(tz, ["GMT", "PST", "UCT"]) end)
    |> Enum.map(fn tz ->
      period = hd(Tzdata.periods_for_time(tz, now_secs, :wall))
      {tz, period[:zone_abbr], period[:utc_off] + period[:std_off]}
    end)
  end
end
