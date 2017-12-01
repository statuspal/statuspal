defmodule StatushqWeb.ServiceIncidentTest do
  use StatushqWeb.ModelCase

  alias Statushq.SPM.ServiceIncident

  @valid_attrs %{incident_id: 42, service_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ServiceIncident.changeset(%ServiceIncident{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ServiceIncident.changeset(%ServiceIncident{}, @invalid_attrs)
    refute changeset.valid?
  end
end
