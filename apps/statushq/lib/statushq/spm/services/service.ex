defmodule Statushq.SPM.Services.Service do
  use Ecto.Schema
  import Ecto.Changeset
  import Statushq.Validators
  alias Statushq.SPM
  alias Statushq.SPM.{ServiceIncident, Incident}

  @allowed_n_services %{
    "free" => 0,
    "startup" => 3,
    "business" => 10,
  }

  def get_allowed_n_services(plan), do: @allowed_n_services[plan] || 0

  schema "services" do
    field :name, :string
    field :ping_url, :string
    field :is_up, :boolean, default: false
    field :response_time_ms, :integer
    field :availability_perc, :float
    field :current_incident_type, :string
    field :status_page_id, :integer
    field :monitoring_enabled, :boolean
    field :auto_incident, :boolean

    many_to_many :incidents, Incident, join_through: ServiceIncident, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :ping_url, :monitoring_enabled, :auto_incident])
    |> validate_required([:name])
    |> validate_monitoring
  end

  def validate_monitoring(changeset) do
    if changeset.changes[:monitoring_enabled] || changeset.data.monitoring_enabled do
      changeset
      |> validate_required([:ping_url])
      |> validate_url(:ping_url)
      |> validate_n_monitored_services()
    else
      changeset
    end
  end

  def validate_n_monitored_services(changeset = %{data: service}) do
    validate_change(changeset, :monitoring_enabled, fn(_, monitoring_enabled) ->
      if monitoring_enabled do
        s_page = SPM.get_page!(service.status_page_id)
        n_services =
          SPM.list_services(s_page) |> Enum.filter(&(&1.id != service.id)) |> length()

        max_n_services = get_allowed_n_services(s_page.plan)
        if n_services >= max_n_services do
          [monitoring_enabled:
            "You have reached your limit of #{max_n_services} monitored "<>
            "services, please upgrade or disable monitoring"]
        else
          []
        end
      else
        []
      end
    end)
  end
end
