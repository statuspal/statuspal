defmodule StatushqWeb.StatusPageController do
  use StatushqWeb, :controller

  alias StatushqWeb.{MailGun, StatusPageView}
  alias Statushq.SPM
  alias Statushq.SPM.StatusPage


  def show(conn, %{"subdomain" => subdomain}) do
    status_page = get_page(subdomain)
    services = SPM.list_page_services(status_page.id)
    incidents = SPM.current_incidents(status_page.id)
    past_incidents = SPM.past_incidents(status_page.id)
    maintenances = SPM.future_incidents(status_page.id)
    render(conn, "show.html", status_page: status_page, services: services,
      incidents: incidents, maintenances: maintenances, past_incidents: past_incidents)
  end

  def subscribe(conn, %{"status_page_subdomain" => subdomain, "subscription" => subscription}) do
    page = get_page(subdomain)
    MailGun.add_list_member("page-#{page.id}", subscription["email"])
    conn
    |> put_flash(:info, "You have been subscribed!")
    |> redirect(to: StatusPageView.sd(status_page_path(conn, :show, subdomain), page))
  end

  def get_page(subdomain) do
    StatusPage |> where(subdomain: ^subdomain) |> Repo.one!
  end
end
