defmodule StatushqWeb.IncidentController do
  use StatushqWeb, :controller

  alias Statushq.SPM.{StatusPage, Incident, IncidentActivity}

  def index(conn, %{"status_page_subdomain" => subdomain}) do
    status_page = get_page(subdomain)
    query = from i in Incident,
      where: i.status_page_id == ^status_page.id,
      order_by: [desc: i.starts_at]

    incidents = Repo.all(query)
    render(conn, "index.html", incidents: incidents, subdomain: subdomain, status_page: status_page)
  end

  def show(conn, %{"status_page_subdomain" => subdomain, "id" => id}) do
    status_page = get_page(subdomain)
    incident = Repo.get_by!(Incident, id: id, status_page_id: status_page.id)
    |> Repo.preload(incident_activities: from(
      a in IncidentActivity, order_by: [desc: a.updated_at], preload: :activity_type
    ))
    |> Repo.preload(:services)

    render(conn, "show.html", incident: incident, subdomain: subdomain, status_page: status_page)
  end

  def get_page(subdomain) do
    StatusPage |> where(subdomain: ^subdomain) |> Repo.one!
  end
end
