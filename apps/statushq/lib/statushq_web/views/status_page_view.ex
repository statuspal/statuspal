defmodule StatushqWeb.StatusPageView do
  use StatushqWeb, :view

  def use_subdomains() do
    System.get_env("MIX_ENV") == "prod" &&
      WithPro.pro?() &&
      Application.get_env(:statushq, :sp_subdomains) == "true"
  end

  def sd(path, status_page) do
    if use_subdomains() do
      p = String.replace(path, "/status_pages/#{status_page.subdomain}", "")
      if p == "", do: "/", else: p
    else
      path
    end
  end

  def sd_url(url, status_page) do
    if use_subdomains() do
      host = Application.get_env(:statushq, StatushqWeb.Endpoint)[:url][:host]
      url
      |> String.replace("/status_pages/#{status_page.subdomain}", "")
      |> String.replace(host, "#{status_page.subdomain}.#{host}")
    else
      url
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
