defmodule StatushqWeb.SharedView do
  use StatushqWeb, :view
  import WithPro
  with_pro do: use StatushqProWeb.SharedView

  def status_page_preview_url(conn, status_page) do
    if(System.get_env("MIX_ENV") != "prod",
      do: status_page_path(conn, :show, status_page),
      else: "https://#{status_page.subdomain}.statushq.co")
  end
end
