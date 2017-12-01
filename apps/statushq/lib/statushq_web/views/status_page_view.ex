defmodule StatushqWeb.StatusPageView do
  use StatushqWeb, :view

  def sd(path, status_page) do
    if System.get_env("MIX_ENV") == "prod" do
      p = String.replace(path, "/status_pages/#{status_page.subdomain}", "")
      if p == "", do: "/", else: p
    else
      path
    end
  end

  def time_zones_options do
    StatushqWeb.LayoutView.time_zones
    |> Enum.sort(&(elem(&1, 2) <= elem(&2, 2)))
    |> Enum.map(fn {name, _abbrev, offset} ->
      mins = round(abs(offset)/60)
      o_minutes = rem(mins, 60)
      o_hours = round((mins - o_minutes) / 60)
      o_minutes = String.pad_leading(Integer.to_string(o_minutes), 2, "0")
      {"#{if offset >= 0, do: "+", else: "-"}#{o_hours}:#{o_minutes} #{name}", name}
    end)
  end
end
