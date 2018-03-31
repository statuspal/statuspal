defmodule StatushqWeb.Admin.ServiceView do
  use StatushqWeb, :view

  def render("subheader.html", assigns) do
    render(StatushqWeb.Admin.SharedView, "main_actions.html", assigns)
  end

  def render("title", _assigns) do
    "Services"
  end

  def is_monitoring_enabled?(changeset) do
    changeset.data.monitoring_enabled && changeset.changes[:monitoring_enabled] != false
  end

  def get_status_name service do
    case service.is_up do true -> "up"; false -> "down"; _ -> "pending" end
  end
end
