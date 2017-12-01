defmodule StatushqWeb.Admin.UserView do
  use StatushqWeb, :view
  import StatushqWeb.Coherence.ViewHelpers

  def render("subheader.html", assigns) do
    render(StatushqWeb.Admin.SharedView, "user_subheader.html", assigns)
  end
end
