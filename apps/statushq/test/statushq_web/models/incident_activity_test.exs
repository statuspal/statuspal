defmodule StatushqWeb.IncidentActivityTest do
  use StatushqWeb.ModelCase

  alias Statushq.SPM.IncidentActivity

  @valid_attrs %{activity_type_id: 42, description: "some content", incident_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = IncidentActivity.changeset(%IncidentActivity{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = IncidentActivity.changeset(%IncidentActivity{}, @invalid_attrs)
    refute changeset.valid?
  end
end
