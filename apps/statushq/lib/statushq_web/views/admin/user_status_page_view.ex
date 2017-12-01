defmodule StatushqWeb.Admin.UserStatusPageView do
  use StatushqWeb, :view

  def is_admin(membership) do
    membership.role == "o" || membership.role == "a"
  end

  def render("subheader.html", assigns) do
    render(StatushqWeb.Admin.SharedView, "main_actions.html", assigns)
  end

  def render("title", _assigns) do
    "Team"
  end
end
