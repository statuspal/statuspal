defmodule Statushq.SPM.IncidentActivity do
  use StatushqWeb, :model
  alias Statushq.SPM.{ActivityType}

  schema "incident_activities" do
    field :description, :string
    field :incident_id, :integer

    belongs_to :activity_type, ActivityType

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:description, :activity_type_id, :incident_id])
    |> validate_required([:description, :activity_type_id])
  end
end
