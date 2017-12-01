defmodule Statushq.SPM.Services.Service do
  use Ecto.Schema
  import Ecto.Changeset
  alias Statushq.SPM.{ServiceIncident, Incident}

  schema "services" do
    field :name, :string
    field :ping_url, :string
    field :is_up, :boolean, default: false
    field :response_time_ms, :integer
    field :availability_perc, :float
    field :current_incident_type, :string
    field :status_page_id, :integer

    many_to_many :incidents, Incident, join_through: ServiceIncident, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :ping_url])
    |> validate_required([:name])
  end
end
