defmodule StatushqWeb.ActivityTypeTest do
  use StatushqWeb.ModelCase

  alias Statushq.SPM.ActivityType

  @valid_attrs %{active: true, key: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ActivityType.changeset(%ActivityType{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ActivityType.changeset(%ActivityType{}, @invalid_attrs)
    refute changeset.valid?
  end
end
