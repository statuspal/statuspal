defmodule Statushq.SPM.ServiceIncident do
  use StatushqWeb, :model

  schema "services_incidents" do
    field :service_id, :integer
    field :incident_id, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:service_id, :incident_id])
    |> validate_required([:service_id, :incident_id])
  end
end
