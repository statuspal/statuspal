defmodule StatushqWeb.PageControllerTest do
  use StatushqWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert redirected_to(conn) == session_path(conn, :new)
  end
end
