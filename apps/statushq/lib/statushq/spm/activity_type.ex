defmodule Statushq.SPM.ActivityType do
  use StatushqWeb, :model

  schema "activity_types" do
    field :name, :string
    field :key, :string
    field :active, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :key, :active])
    |> validate_required([:name, :key, :active])
  end
end
