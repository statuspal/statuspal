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
    incident = Repo.get!(Incident, id)
    |> Repo.preload(incident_activities: from(
      a in IncidentActivity, order_by: [desc: a.updated_at], preload: :activity_type
    ))
    |> Repo.preload(:services)

    time_elapsed = if incident.ends_at, do: calculate_time_elapsed(incident), else: false

    render(conn, "show.html", incident: incident, subdomain: subdomain, status_page: status_page, time_elapsed: time_elapsed)
  end

  def calculate_time_elapsed incident do
    minutes = Timex.Duration.diff(
      to_duration(incident.ends_at),
      to_duration(incident.starts_at),
      :minutes
    )
    hours = div(minutes, 60)
    minutes = rem(minutes, 60)
    {hours, minutes}
  end

  def to_duration ecto_time do
    ecto_time |> NaiveDateTime.to_time |> Timex.Duration.from_time
  end

  def get_page(subdomain) do
    StatusPage |> where(subdomain: ^subdomain) |> Repo.one!
  end
end
