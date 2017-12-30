defmodule StatushqWeb.Admin.ServiceView do
  use StatushqWeb, :view

  def render("subheader.html", assigns) do
    render(StatushqWeb.Admin.SharedView, "main_actions.html", assigns)
  end

  def render("title", _assigns) do
    "Services"
  end

  def is_monitoring_enabled?(changeset) do
    !changeset.changes[:monitoring_enabled] && !changeset.data.monitoring_enabled
  end
end
