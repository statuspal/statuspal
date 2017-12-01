defmodule StatushqWeb.Admin.UserStatusPageController do
  use StatushqWeb, :controller
  import StatushqWeb.Loaders

  alias StatushqWeb.{UserStatusPageEmail, Mailer}
  alias Statushq.Accounts
  alias Statushq.Accounts.UserStatusPage
  alias Statushq.SPM.{StatusPage}

  plug Coherence.Authentication.Session, [protected: true]

  plug :load_resource, model: StatusPage, id_name: "status_page_subdomain",
    id_field: "subdomain", persisted: true

  plug :authorize_resource,[model: StatusPage, id_name: "status_page_subdomain",
    id_field: "subdomain", persisted: true] when action in [:index, :new, :create]

  plug :load_and_authorize_resource, [model: UserStatusPage, id_name: "members_id"]
    when action in [:accept_invite, :decline_invite]

  plug :load_and_authorize_resource, [model: UserStatusPage]
    when not action in [:accept_invite, :decline_invite]

  plug :load_active_incidents when action in [:index, :new, :edit, :create]

  def index(conn, %{"status_page_subdomain" => _subdomain}) do
    memberships = Accounts.list_membershipts(conn.assigns.status_page)
    user = Coherence.current_user(conn)
    membership = Enum.find(memberships, &(&1.user_id === user.id))

    render(conn, "index.html", users_status_pages: memberships, membership: membership)
  end

  def new(conn, %{"status_page_subdomain" => subdomain}) do
    changeset = Accounts.change_membership(%UserStatusPage{})
    render(conn, "new.html", changeset: changeset, subdomain: subdomain)
  end

  def create(conn, %{"status_page_subdomain" => subdomain, "user_status_page" => params}) do
    case Accounts.create_invite(conn.assigns.status_page, params) do
      {:ok, user_status_page} ->
        url = admin_status_page_url(conn, :show, subdomain)
        UserStatusPageEmail.invite(user_status_page, url, conn.assigns.status_page)
        |> Mailer.deliver

        conn
        |> put_flash(:info, "Member invited successfully.")
        |> redirect(to: admin_status_page_members_path(conn, :index, subdomain))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, subdomain: subdomain)
    end
  end

  def accept_invite(conn = %{assigns: assigns}, %{"status_page_subdomain" => _, "members_id" => _id}) do
    case Accounts.accept_invite(assigns.user_status_page, assigns.current_user) do
      {:ok, _user_status_page} ->
        conn
        |> put_flash(:info, "Membership successfully.")
        |> redirect(to: admin_status_page_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error accepting the invitation")
        |> redirect(to: admin_status_page_path(conn, :index))
    end
  end

  def decline_invite(conn, %{"status_page_subdomain" => _subdomain, "members_id" => id}) do
    Accounts.delete_membership!(id)
    conn
    |> put_flash(:info, "Invitation declined successfully")
    |> redirect(to: admin_status_page_path(conn, :index))
  end

  def edit(conn, %{"status_page_subdomain" => subdomain, "id" => id}) do
    user_status_page = Accounts.get_membership!(id, preload_user: true)
    changeset = Accounts.change_membership(user_status_page)

    render(conn, "edit.html", user_status_page: user_status_page,
      changeset: changeset, subdomain: subdomain)
  end

  def update(conn, %{"status_page_subdomain" => subdomain, "id" => id, "user_status_page" => params}) do
    case Accounts.update_membership(id, params) do
      {:ok, _user_status_page} ->
        conn
        |> put_flash(:info, "Membership successfully.")
        |> redirect(to: admin_status_page_members_path(conn, :index, subdomain))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset, subdomain: subdomain)
    end
  end

  def delete(conn, %{"status_page_subdomain" => subdomain, "id" => id}) do
    Accounts.delete_membership!(id)
    conn
    |> put_flash(:info, "Member deleted successfully.")
    |> redirect(to: admin_status_page_members_path(conn, :index, subdomain))
  end
end
