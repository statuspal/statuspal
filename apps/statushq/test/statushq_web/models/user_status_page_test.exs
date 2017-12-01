defmodule StatushqWeb.UserStatusPageTest do
  use StatushqWeb.ModelCase

  alias Statushq.Accounts.UserStatusPage

  @valid_attrs %{role: "some content", status_page_id: 42, user_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserStatusPage.status_page_creation_changeset(%UserStatusPage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserStatusPage.status_page_creation_changeset(%UserStatusPage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
