defmodule StatushqWeb.ServiceTest do
  use StatushqWeb.ModelCase

  alias Statushq.SPM.Services.Service

  @valid_attrs %{availability_perc: "120.5", current_incident_type: "some content", is_up: true, name: "some content", ping_url: "some content", response_time_ms: 42, status_page_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Service.changeset(%Service{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Service.changeset(%Service{}, @invalid_attrs)
    refute changeset.valid?
  end
end
