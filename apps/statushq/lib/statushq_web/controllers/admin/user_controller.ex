defmodule StatushqWeb.Admin.UserController do
  use StatushqWeb, :controller

  plug Coherence.Authentication.Session, [protected: true]

  def edit(conn, _) do
    user = Coherence.current_user(conn)
    render(conn, "edit.html", changeset: Statushq.Accounts.User.changeset(user), action: :update)
  end
end
