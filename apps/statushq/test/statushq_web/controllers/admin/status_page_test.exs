defmodule StatushqWeb.Admin.StatusPageControllerTest do
  # use StatushqWeb.ConnCase
  # import StatushqWeb.Factory

  # alias StatushqWeb.Admin.StatusPage
  # @valid_attrs %{logo: "some content", name: "some content", subdomain: "some content", url: "some content"}
  # @invalid_attrs %{}

  # test "lists all entries on index", %{conn: conn} do
  #   conn = assign(conn, :current_user, insert(:user, %{}))
  #   conn = get conn, admin_status_page_path(conn, :index)
  #   assert html_response(conn, 200) =~ "Status Pages you are member of"
  # end

  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, admin_status_page_path(conn, :new)
  #   assert html_response(conn, 200) =~ "New status page"
  # end
  #
  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, admin_status_page_path(conn, :create), status_page: @valid_attrs
  #   assert redirected_to(conn) == admin_status_page_path(conn, :index)
  #   assert Repo.get_by(StatusPage, @valid_attrs)
  # end
end
