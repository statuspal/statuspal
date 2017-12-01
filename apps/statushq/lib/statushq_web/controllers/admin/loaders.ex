defmodule StatushqWeb.Loaders do
  import Plug.Conn
  import Ecto.Query

  alias Statushq.Accounts.UserStatusPage
  alias Statushq.SPM
  alias Statushq.SPM.{StatusPage}
  alias Statushq.Repo

  def load_active_incidents(conn, _params) do
    conn
    |> assign(:active_incidents, SPM.current_incidents(conn.assigns[:status_page].id, false))
    |> assign(:permission,
      Repo.get_by(UserStatusPage,
        status_page_id: conn.assigns.status_page.id,
        user_id: conn.assigns[:current_user].id
      )
    )
  end

  def load_my_pages(conn, _params) do
    if conn.assigns[:current_user] do
      query = from p in StatusPage,
        join: m in assoc(p, :users_status_pages),
        where: m.user_id == ^conn.assigns[:current_user].id

      assign(conn, :my_status_pages, Repo.all(query))
    else
      conn
    end
  end

  def load_invitations(conn, _params) do
    user = conn.assigns.current_user
    if user do
      query = from m in UserStatusPage, where: m.email == ^user.email and is_nil(m.user_id)
      assign(conn, :invitations, query |> Repo.all |> Repo.preload(:status_page))
    else
      conn
    end
  end
end
