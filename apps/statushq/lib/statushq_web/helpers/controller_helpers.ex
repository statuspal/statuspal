defmodule StatushqWeb.ControllerHelpers do
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import Plug.Conn, only: [halt: 1]

  def handle_not_found(conn) do
    conn
    |> put_flash(:error, "That resource does not exist!")
    |> redirect(to: "/admin")
    |> halt
  end

  def handle_unauthorized(conn) do
    conn
    |> put_flash(:error, "You dont have permissions to access that resource!")
    |> redirect(to: "/admin")
    |> halt
  end
end
