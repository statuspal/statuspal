defmodule StatushqWeb.Admin.IncidentView do
  use StatushqWeb, :view
  alias Statushq.Repo
  alias Statushq.SPM.{Incident, ActivityType}
  import Ecto.Query, only: [where: 2]

  def render("subheader.html", assigns) do
    render(StatushqWeb.Admin.SharedView, "main_actions.html", assigns)
  end

  def type_options(params) do
    Incident.types
    |> filter_types(params)
    |> Enum.reject(fn({t, _}) -> !t end)
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Enum.into(%{})
  end

  def filter_types(types, %{"maintenance" => "true"}) do
    Enum.filter(types, fn {k, _v} -> k == "s" end)
  end
  def filter_types(types, _) do
    Enum.filter(types, fn {k, _v} -> k != "s" end)
  end

  def maintenance_type(_conn) do
    ActivityType |> where(key: "scheduled") |> Repo.one
  end
end
