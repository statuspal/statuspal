defmodule StatushqWeb.Admin.ServiceController do
  use StatushqWeb, :controller
  import StatushqWeb.Loaders

  alias Statushq.SPM
  alias Statushq.SPM.Services.Service
  alias Statushq.SPM.{StatusPage}

  plug Coherence.Authentication.Session, [protected: true]
  plug :load_resource, model: StatusPage, id_name: "status_page_subdomain",
    id_field: "subdomain", persisted: true
  plug :authorize_resource, [model: StatusPage, persisted: true] when action in [:index, :new, :create]
  plug :load_and_authorize_resource, model: Service
  plug :load_active_incidents

  def index(conn, %{"status_page_subdomain" => subdomain}) do
    services = SPM.list_services(conn.assigns.status_page)
    render(conn, "index.html", services: services, subdomain: subdomain)
  end

  def new(conn, %{"status_page_subdomain" => subdomain}) do
    changeset = SPM.change_service(%Service{})
    render(conn, "new.html", changeset: changeset, subdomain: subdomain)
  end

  def create(conn, %{"status_page_subdomain" => subdomain, "service" => attrs}) do
    case SPM.create_service(conn.assigns.status_page, attrs) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, "Service created successfully.")
        |> redirect(to: admin_status_page_path(conn, :show, subdomain))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, subdomain: subdomain)
    end
  end

  def edit(conn, %{"status_page_subdomain" => subdomain, "id" => _id}) do
    changeset = SPM.change_service(conn.assigns.service)
    render(conn, "edit.html", changeset: changeset, subdomain: subdomain)
  end

  def update(conn, %{"status_page_subdomain" => subdomain, "id" => _id, "service" => attrs}) do
    case SPM.update_service(conn.assigns.service, attrs) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, "Service updated successfully.")
        |> redirect(to: admin_status_page_path(conn, :show, subdomain))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset, subdomain: subdomain)
    end
  end

  def delete(conn, %{"status_page_subdomain" => subdomain, "id" => _id}) do
    SPM.delete_service!(conn.assigns.service)

    conn
    |> put_flash(:info, "Service deleted successfully.")
    |> redirect(to: admin_status_page_path(conn, :show, subdomain))
  end
end
