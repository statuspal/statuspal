defmodule StatushqWeb.Admin.IncidentActivityController do
  use StatushqWeb, :controller
  import StatushqWeb.Loaders

  alias Statushq.SPM
  alias Statushq.SPM.{IncidentActivity, Incident, StatusPage, ActivityType}
  alias StatushqWeb.Admin.Notification

  plug Coherence.Authentication.Session, [protected: true]
  plug :load_resource, model: StatusPage, id_name: "status_page_subdomain",
    id_field: "subdomain", persisted: true
  plug :load_and_authorize_resource, model: Incident, persisted: true, id_name: "incident_id"
  plug :load_and_authorize_resource, model: IncidentActivity
  plug :load_active_incidents

  def new(conn, %{"status_page_subdomain" => subdomain, "incident_id" => incident_id}) do
    changeset = IncidentActivity.changeset(%IncidentActivity{})
    render(conn, "new.html", changeset: changeset, subdomain: subdomain, incident_id: incident_id,
      activity_types: get_activity_types())
  end

  def create(conn, %{"status_page_subdomain" => subdomain, "incident_id" => incident_id,
    "incident_activity" => params}) do
    {id, _} = Integer.parse(incident_id)
    changeset = IncidentActivity.changeset(%IncidentActivity{incident_id: id}, params)

    case Repo.insert(changeset) do
      {:ok, update} ->
        SPM.close_incident_if_cecessary(id, params, subdomain)
        Notification.incident_update_notification(
          conn, params, conn.assigns.status_page, conn.assigns.incident, update
        )

        conn
        |> put_flash(:info, "Incident activity created successfully.")
        |> redirect(to: admin_status_page_path(conn, :show, subdomain))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, subdomain: subdomain,
          incident_id: incident_id, activity_types: get_activity_types())
    end
  end

  def edit(conn, %{"status_page_subdomain" => subdomain, "incident_id" => incident_id, "id" => id}) do
    incident_activity = Repo.get!(IncidentActivity, id)
    changeset = IncidentActivity.changeset(incident_activity)
    render(conn, "edit.html", incident_activity: incident_activity, changeset: changeset,
      subdomain: subdomain, incident_id: incident_id, activity_types: get_activity_types())
  end

  def update(conn, %{"status_page_subdomain" => subdomain, "incident_id" => incident_id, "id" => id,
    "incident_activity" => incident_activity_params}) do
    incident_activity = Repo.get!(IncidentActivity, id)
    changeset = IncidentActivity.changeset(incident_activity, incident_activity_params)

    case Repo.update(changeset) do
      {:ok, _incident_activity} ->
        conn
        |> put_flash(:info, "Incident activity updated successfully.")
        |> redirect(to: admin_status_page_path(conn, :show, subdomain))
      {:error, changeset} ->
        render(conn, "edit.html", incident_activity: incident_activity, changeset: changeset,
          subdomain: subdomain, incident_id: incident_id, activity_types: get_activity_types())
    end
  end

  def delete(conn, %{"status_page_subdomain" => subdomain, "incident_id" => _, "id" => id}) do
    incident_activity = Repo.get!(IncidentActivity, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(incident_activity)

    conn
    |> put_flash(:info, "Incident activity deleted successfully.")
    |> redirect(to: admin_status_page_path(conn, :show, subdomain))
  end

  def get_activity_types do
    Repo.all(ActivityType) |> Enum.map(fn s -> {s.name, s.id} end)
  end
end
