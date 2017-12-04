defmodule StatushqWeb.Admin.IncidentActivityView do
  use StatushqWeb, :view

  def current_status(incident) do
    [_activity, type] = Statushq.SPM.incident_status(incident)
    type
  end

  def render("subheader.html", assigns) do
    render(StatushqWeb.Admin.SharedView, "main_actions.html", assigns)
  end

  def get_activity_types(conn) do
    if conn.assigns.incident do
      if conn.assigns.incident.type != "s" do
        Enum.filter(conn.assigns.activity_types, fn {k, _id} ->
          k != "Retroactive" && k != "Scheduled"
        end)
      else
        Enum.filter(conn.assigns.activity_types, fn {k, _id} -> k == "Resolved" end)
      end
    else
      conn.assigns.activity_types
    end
  end

  def get_activity_default_value(conn) do
    if !conn.assigns.incident && conn.params["maintenance"] === "true" do
      StatushqWeb.Admin.IncidentView.maintenance_type(conn).id
    end
  end
end
