defmodule StatushqWeb.Admin.IncidentController do
  use StatushqWeb, :controller
  import StatushqWeb.Loaders

  alias Statushq.SPM
  alias Statushq.SPM.{StatusPage, Incident, ActivityType}
  alias StatushqWeb.Admin.Notification

  plug Coherence.Authentication.Session, [protected: true]
  plug :load_resource, model: StatusPage, id_name: "status_page_subdomain",
    id_field: "subdomain", persisted: true
  plug :authorize_resource, [model: StatusPage, persisted: true] when action in [:index, :new, :create]
  plug :load_and_authorize_resource, model: Incident
  plug :load_active_incidents
  plug :load_activity_types

  def index(conn, %{"status_page_subdomain" => subdomain}) do
    query = from i in Incident,
      join: a in assoc(i, :incident_activities),
      group_by: i.id,
      select: {i, count(a.id)},
      where: i.status_page_id == ^get_page(conn).id,
      order_by: [desc: i.inserted_at]

    incidents = Repo.all(query)
    render(conn, "index.html", incidents: incidents, subdomain: subdomain)
  end

  def new(conn, %{"status_page_subdomain" => subdomain}) do
    changeset = Incident.changeset(%Incident{services_incidents: []})
    render(conn, "new.html", changeset: changeset, subdomain: subdomain,
      services: get_services(conn))
  end

  def create(conn, %{"status_page_subdomain" => subdomain, "incident" => incident_params}) do
    page = get_page(conn)
    changeset = Incident.changeset(
      %Incident{status_page_id: page.id}, incident_params, conn.assigns.status_page.time_zone
    )

    case Repo.insert(changeset) do
      {:ok, incident} ->
        SPM.update_service_statuses(page.id)
        opts = incident_params["incident_activities"]["0"]
        update = hd(incident.incident_activities)
        Notification.incident_update_notification(conn, opts, page, incident, update)

        conn
        |> put_flash(:info, "Incident created successfully.")
        |> redirect(to: admin_status_page_path(conn, :show, subdomain))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, subdomain: subdomain,
          services: get_services(conn))
    end
  end

  def show(conn, %{"status_page_subdomain" => subdomain, "id" => id}) do
    incident = Repo.get!(Incident, id) |> Repo.preload(incident_activities: :activity_type)
    render(conn, "show.html", incident: incident, subdomain: subdomain)
  end

  def edit(conn, %{"status_page_subdomain" => subdomain, "id" => id}) do
    incident = Repo.get!(Incident, id)
    changeset = Incident.changeset(incident)
    render(conn, "edit.html", incident: incident, changeset: changeset,
      subdomain: subdomain, services: get_services(conn))
  end

  def update(conn, %{"status_page_subdomain" => subdomain, "id" => id, "incident" => incident_params}) do
    incident = Repo.get!(Incident, id)
    changeset = Incident.changeset(
      incident, incident_params, conn.assigns.status_page.time_zone
    )

    case Repo.update(changeset) do
      {:ok, _incident} ->
        SPM.update_service_statuses(get_page(conn).id)
        conn
        |> put_flash(:info, "Incident updated successfully.")
        |> redirect(to: admin_status_page_path(conn, :show, subdomain))
      {:error, changeset} ->
        render(conn, "edit.html", incident: incident, changeset: changeset, subdomain: subdomain, services: get_services(conn))
    end
  end

  def delete(conn, %{"status_page_subdomain" => subdomain, "id" => id}) do
    incident = Repo.get!(Incident, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(incident)
    SPM.update_service_statuses(get_page(conn).id)

    conn
    |> put_flash(:info, "Incident deleted successfully.")
    |> redirect(to: admin_status_page_incident_path(conn, :index, subdomain))
  end

  def load_activity_types(conn, _params) do
    types = Repo.all(ActivityType)
    |> Enum.filter(fn s -> filter_types(s, conn.params) end)
    |> Enum.map(fn s -> {s.name, s.id} end)
    |> Enum.into(%{})

    assign(conn, :activity_types, types)
  end

  def filter_types(type, %{"maintenance" => "true"}) do
    Enum.member?(["scheduled", "resolved", "monitoring"], type.key)
  end
  def filter_types(type, _), do: type.key != "scheduled"

  def get_services(conn) do
    SPM.list_services(conn.assigns.status_page)
    |> Enum.map(fn s -> {s.name, s.id} end) |> Enum.into(%{})
  end

  def get_page(conn) do
    conn.assigns.status_page
  end
end
