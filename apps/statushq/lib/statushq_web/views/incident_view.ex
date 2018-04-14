defmodule StatushqWeb.IncidentView do
  use StatushqWeb, :view

  def time_elapsed(%{starts_at: starts_at, ends_at: ends_at}) do
    secs = DateTime.diff(
      if(ends_at, do: DateTime.from_naive!(ends_at, "Etc/UTC"), else: DateTime.utc_now()),
      DateTime.from_naive!(starts_at, "Etc/UTC")
    )
    minutes_diff = round(secs / 60)
    days = div(minutes_diff, 60 * 24)
    hours = rem(div(minutes_diff, 60), 24)
    minutes = rem(minutes_diff, 60)

    resp = []
    resp = if days > 0, do: resp ++ ["#{days} days"], else: resp
    resp = if hours > 0, do: resp ++ ["#{hours} hours"], else: resp
    resp = if minutes > 0, do: resp ++ ["#{minutes} minutes"], else: resp
    Enum.join(resp, ",")
  end
end
