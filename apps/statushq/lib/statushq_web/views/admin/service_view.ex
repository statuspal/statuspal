defmodule StatushqWeb.Admin.ServiceView do
  use StatushqWeb, :view

  def render("subheader.html", assigns) do
    render(StatushqWeb.Admin.SharedView, "main_actions.html", assigns)
  end

  def render("title", _assigns) do
    "Services"
  end
end
