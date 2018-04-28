defmodule StatushqWeb.StatusPageController do
  use StatushqWeb, :controller

  alias StatushqWeb.{MailGun, StatusPageView}
  alias Statushq.SPM
  alias Statushq.SPM.StatusPage
  alias StatushqWeb.Admin.Monitoring


  def show(conn, %{"subdomain" => subdomain}) do
    status_page = get_page(subdomain)
    services = SPM.list_page_services(status_page.id)
    incidents = SPM.current_incidents(status_page.id)
    past_incidents = SPM.past_incidents(status_page.id)
    maintenances = SPM.future_incidents(status_page.id)
    {uptime, last_incidents} = SPM.get_incidents_history(status_page, 60)
    r_times = services
    |> Enum.filter(fn(s) -> s.monitoring_enabled end)
    |> Enum.map(fn(s) -> [s.name, get_response_times(s)] end)

    render(conn, "show.html", status_page: status_page, services: services,
      incidents: incidents, maintenances: maintenances, past_incidents: past_incidents,
      last_incidents: last_incidents, uptime: uptime, r_times: r_times)
  end

  def get_response_times(service) do
    Monitoring.get_response_times(service)
    |> Enum.map(fn(%{day: day, time_ms: ms}) ->
      %{day: Date.from_erl!(day), time_ms: Decimal.to_float(ms)/1000} end)
  end

  def subscribe(conn, %{"status_page_subdomain" => subdomain, "subscription" => subscription}) do
    page = get_page(subdomain)
    {:ok, resp} = MailGun.get_list("page-#{page.id}")
    if resp.status_code != 200 do
      MailGun.create_list("page-#{page.id}", page.name)
    end
    MailGun.add_list_member("page-#{page.id}", subscription["email"])
    conn
    |> put_flash(:info, "You have been subscribed!")
    |> redirect(to: StatusPageView.sd(status_page_path(conn, :show, subdomain), page))
  end

  def get_page(subdomain) do
    StatusPage |> where(subdomain: ^subdomain) |> Repo.one!
  end
end
