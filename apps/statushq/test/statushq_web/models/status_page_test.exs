defmodule StatushqWeb.StatusPageTest do
  use StatushqWeb.ModelCase

  alias Statushq.SPM.StatusPage

  @valid_attrs %{name: "some content", subdomain: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = StatusPage.changeset(%StatusPage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = StatusPage.changeset(%StatusPage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
