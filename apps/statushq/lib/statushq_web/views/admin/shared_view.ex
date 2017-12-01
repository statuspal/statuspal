defmodule StatushqWeb.Admin.SharedView do
  use StatushqWeb, :view
  import WithPro

  def active_class(conn, view, template) do
    if conn.private.phoenix_view == view && conn.private.phoenix_template == template, do: "active"
  end
end
