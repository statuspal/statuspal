defmodule StatushqWeb.Admin.IncidentActivityView do
  use StatushqWeb, :view

  def current_status(incident) do
    [_activity, type] = Statushq.SPM.incident_status(incident)
    type
  end

  def render("subheader.html", assigns) do
    render(StatushqWeb.Admin.SharedView, "main_actions.html", assigns)
  end
end
