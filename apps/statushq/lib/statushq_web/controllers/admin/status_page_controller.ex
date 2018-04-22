defmodule StatushqWeb.Admin.StatusPageController do
  import StatushqWeb.Loaders
  import WithPro
  use StatushqWeb, :controller
  with_pro do: use StatushqProWeb.Admin.StatusPageController

  alias Statushq.SPM
  alias Statushq.SPM.{StatusPage}

  plug Coherence.Authentication.Session, [protected: true] when action != :show

  plug :load_and_authorize_resource, [model: StatusPage, id_name: "subdomain",
    id_field: "subdomain"] when not action in [:billing, :setup_billing, :update_billing, :design]

  plug :load_and_authorize_resource, [model: StatusPage, id_name: "status_page_subdomain",
    id_field: "subdomain"] when action in [:billing, :setup_billing, :update_billing, :design]

  plug :load_active_incidents when action not in [:index, :new, :create]

  def index(conn, _params) do
    status_page = SPM.get_page(conn.assigns.current_user)
    if status_page do
      redirect(conn, to: admin_status_page_path(conn, :show, status_page))
    else
      redirect(conn, to: admin_status_page_path(conn, :new))
    end
  end

  def new(conn, _params) do
    changeset = SPM.change_page(%StatusPage{time_zone: "Etc/UTC"})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"status_page" => attrs}) do
    case SPM.create_page(conn.assigns.current_user, attrs) do
      {:ok, status_page} ->
        StatusPage.avatar_changeset(status_page, attrs) |> Repo.update

        conn
        |> put_flash(:info, "Welcome to your new status page!")
        |> redirect(to: admin_status_page_path(conn, :show, status_page,
          status_page_created: "true"))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"subdomain" => _subdomain}) do
    services = SPM.list_services(conn.assigns.status_page)
    render(conn, "show.html", services: services)
  end

  def edit(conn, %{"subdomain" => _subdomain}) do
    changeset = SPM.change_page(conn.assigns.status_page)
    render(conn, "edit.html", changeset: changeset)
  end

  def design(conn, %{"status_page_subdomain" => _subdomain}) do
    changeset = SPM.change_page(conn.assigns.status_page)
    render(conn, "design.html", changeset: changeset)
  end

  def update(conn, params = %{"subdomain" => _subdomain, "status_page" => attrs}) do
    case SPM.update_page(conn.assigns.status_page, attrs) do
      {:ok, status_page} ->
        path = if(params["design"],
          do: admin_status_page_design_path(conn, :design, status_page),
          else: admin_status_page_path(conn, :edit, status_page)
        )
        conn
        |> put_flash(:info, "Status page updated successfully.")
        |> redirect(to: path)
      {:error, changeset} ->
        render(conn,
          if(params["design"], do: "design.html", else: "edit.html"),
          changeset: changeset)
    end
  end

  def delete(conn, %{"subdomain" => _subdomain}) do
    SPM.delete_page!(conn.assigns.status_page)
    conn
    |> put_flash(:info, "Status page deleted successfully.")
    |> redirect(to: admin_status_page_path(conn, :index))
  end
end
