defmodule StatushqWeb.PageControllerTest do
  use StatushqWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    if WithPro.pro?() do
      assert html_response(conn, 200) =~ "Statuspal"
    else
      assert redirected_to(conn) == session_path(conn, :new)
    end
  end
end
