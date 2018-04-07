defmodule StatushqWeb.PageController do
  use StatushqWeb, :controller
  import WithPro
  with_pro do: use StatushqProWeb.PageController

  alias StatushqWeb.StatusPageView
  alias Statushq.SPM

  def index(conn, _params) do
    status_page = SPM.get_page()
    if status_page do
      services = SPM.list_page_services(status_page.id)
      incidents = SPM.current_incidents(status_page.id)
      past_incidents = SPM.past_incidents(status_page.id)
      maintenances = SPM.future_incidents(status_page.id)
      {uptime, last_incidents} = SPM.get_incidents_history(status_page, 60)

      render(conn, StatusPageView, "show.html", status_page: status_page, services: services,
        incidents: incidents, maintenances: maintenances, past_incidents: past_incidents,
        last_incidents: last_incidents, uptime: uptime)
    else
      conn
      |> put_flash(:info, "Login to setup your status page")
      |> redirect(to: session_path(conn, :new))
    end
  end
end
