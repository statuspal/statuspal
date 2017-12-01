defmodule StatushqWeb.IncidentTest do
  use StatushqWeb.ModelCase

  alias Statushq.SPM.Incident

  @valid_attrs %{"starts_at" => "2017-10-16T12:26:54", "ends_at" => "2017-10-16T12:36:54",
    "title" => "some content", "type" => "some content", "services_incidents" => ["1"]}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Incident.changeset(%Incident{}, @valid_attrs, "UTC")
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Incident.changeset(%Incident{}, @invalid_attrs)
    refute changeset.valid?
  end
end
