defmodule Statushq.SPM.Incident do
  use StatushqWeb, :model
  alias Statushq.Repo
  alias Statushq.SPM.{ServiceIncident, IncidentActivity, Services.Service, Incident, ActivityType}

  schema "incidents" do
    field :title, :string
    field :type, :string
    field :starts_at, :naive_datetime
    field :ends_at, :naive_datetime
    field :status_page_id, :integer
    field :monitored, :boolean

    has_many :services_incidents, ServiceIncident, on_delete: :delete_all, on_replace: :delete
    has_many :incident_activities, IncidentActivity, on_delete: :delete_all, on_replace: :delete
    many_to_many :services, Service, join_through: ServiceIncident

    timestamps()
  end

  @types %{"i" => "Minor Incident", "a" => "Major Incident", "s" => "Scheduled Maintenance", nil => "No known issues at this time"}

  def types, do: @types
  def type_icons, do: %{"i" => "glyphicon-minus-sign", "a" => "glyphicon-remove", "s" => "glyphicon-cog", nil => "glyphicon-ok"}
  def type_colors, do: %{"i" => "orange", "a" => "#ff2a2a", "s" => "blue", nil => "#568c56"}

  def monitored_changeset(service) do
    activity_type = Repo.get_by!(ActivityType, key: "issue")
    activity = %IncidentActivity{
      activity_type_id: activity_type.id,
      description: "Our monitoring system has found out the service #{service.name} is "<>
        "currently unresponsive, we'll look into this now and let you know as soon as we know more.",
    }
    change(%Incident{}, %{
      title: "Service #{service.name} seems to be down",
      type: "a",
      starts_at: DateTime.utc_now(),
      status_page_id: service.status_page_id,
      monitored: true
    })
    |> put_assoc(:services_incidents, [%ServiceIncident{service_id: service.id}])
    |> put_assoc(:incident_activities, [activity])
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}, time_zone \\ nil) do
    struct
    |> Repo.preload(:incident_activities)
    |> Repo.preload(:services_incidents)
    |> cast(params, [:title, :type])
    |> cast_localize_dates(params, [:starts_at, :ends_at], time_zone)
    |> cast_assoc(:incident_activities)
    |> put_assoc(:services_incidents, parse_services(params))
    |> validate_required([:title, :type, :starts_at])
    |> validate_length(:services_incidents, min: 1,
        message: "Select at least one affected service")
  end

  def cast_localize_dates(struct, _params, _fields, nil), do: struct

  def cast_localize_dates(struct, _params, [], _time_zone), do: struct

  def cast_localize_dates(struct, params, [field | r_fields], time_zone) do
    attr = params[Atom.to_string(field)]
    if attr && attr != "" do
      d = Timex.parse!("#{attr} #{time_zone}", "%Y-%m-%dT%H:%M:%S %Z", :strftime)
      |> Timex.Timezone.convert("UTC")
      |> DateTime.to_naive

      cast_localize_dates(put_change(struct, field, d), params, r_fields, time_zone)
    else
      struct
    end
  end

  def parse_services(params) do
    (params["services_incidents"] || %{}) |> Enum.map(&s_incident_struct/1)
  end

  def s_incident_struct str_id do
    {i, _} = Integer.parse(str_id)
    %ServiceIncident{service_id: i}
  end
end
