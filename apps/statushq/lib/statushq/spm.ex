defmodule Statushq.SPM do
  @moduledoc """
  The Status Pages Management context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  import Statushq.SPM.Services
  import WithPro
  with_pro do: use StatushqPro.SPM

  alias Statushq.Repo
  alias Statushq.Accounts.{User, UserStatusPage}
  alias Statushq.SPM.{StatusPage, IncidentActivity, Incident, ActivityType, Services, Services.Service}

  # StatusPages

  def list_pages(user) do
    from(p in StatusPage,
      join: m in assoc(p, :users_status_pages),
      where: m.user_id == ^user.id, select: [p, m])
    |> Repo.all
  end

  def list_owned_pages_q(user) do
    from(p in StatusPage,
      join: m in assoc(p, :users_status_pages),
      where: m.user_id == ^user.id and m.role == "o")
  end
  def list_owned_pages(user), do: list_owned_pages_q(user) |> Repo.all

  def change_page(%StatusPage{} = page, attrs \\ %{}) do
    StatusPage.changeset(page, attrs)
  end

  def create_page(user, attrs) do
    StatusPage.creation_changeset(%StatusPage{}, attrs, user.id)
    |> Repo.insert
  end

  def update_page(%StatusPage{} = page, attrs) do
    page |> change_page(attrs) |> Repo.update
  end

  def get_page!(id) when is_integer(id), do: StatusPage |> Repo.get!(id)
  def get_page!(subdomain), do: StatusPage |> Repo.get_by!(subdomain: subdomain)
  def get_page(id), do: StatusPage |> Repo.get(id)
  def get_page_by_domain(domain) do
    from(p in StatusPage, where: p.domain == ^domain and p.plan != "free")
    |> Repo.one!()
  end

  def get_page(%User{} = user) do
    from(p in StatusPage,
      join: m in assoc(p, :users_status_pages),
      where: m.user_id == ^user.id, select: p, limit: 1)
    |> Repo.one
  end

  def get_page do
    StatusPage |> limit(1) |> Repo.one
  end

  def delete_page!(%StatusPage{} = page), do: page |> Repo.delete!

  def list_page_services(page_id) do
    Service |> where(status_page_id: ^page_id) |> Repo.all
  end

  def __incidents_from_page_query__(page_id, query_process, preload_data \\ true) do
    query = from(i in Incident,
      join: s in assoc(i, :services),
      where: s.status_page_id == ^page_id,
      distinct: i.id)
    |> query_process.()
    |> Repo.all()

    if preload_data do
      query
      |> Repo.preload(incident_activities: from(a in IncidentActivity, order_by: a.inserted_at))
      |> Repo.preload(:services)
    else
      query
    end
  end

  def current_incidents(page_id, preload_data \\ true) do
    __incidents_from_page_query__(page_id, fn(query) ->
      from i in query,
        where: ^now() >= i.starts_at and (i.ends_at > ^now() or is_nil(i.ends_at))
    end, preload_data)
  end

  def past_incidents(page_id) do
    __incidents_from_page_query__(page_id, fn(query) ->
      from i in query,
        where: i.ends_at > ^Timex.shift(now(), days: -3) and i.ends_at <= ^now()
    end)
  end

  def future_incidents(page_id) do
    __incidents_from_page_query__(page_id, fn(query) ->
      from i in query, where: i.starts_at > ^now() and i.type == "s"
    end)
  end

  def now(), do: DateTime.utc_now

  # Services

  defdelegate monitored_services(status_page), to: Services

  def list_services(page) do
    Service |> where(status_page_id: ^page.id) |> order_by([desc: :name]) |> Repo.all
  end

  def change_service(%Service{} = service, attrs \\ %{}) do
    Service.changeset(service, attrs)
  end

  def create_service(page, attrs) do
    change_service(%Service{status_page_id: page.id}, attrs) |> Repo.insert
  end

  def update_service(service, attrs) do
    change_service(service, attrs) |> Repo.update
  end

  def set_service_up(service, up) do
    Ecto.Changeset.change(service, %{is_up: up}) |> Repo.update
  end

  def set_services_up(service_ids, up) do
    from(s in Service, where: s.id in ^service_ids)
    |> Repo.update_all(set: [is_up: up])
  end

  def get_services_with_pages(service_ids) do
    from(serv in Service,
      join: page in assoc(serv, :status_page),
      join: up in UserStatusPage,
      join: user in User,
      preload: [status_page: {page, users: user}],
      where: serv.id in ^service_ids and page.id == up.status_page_id
        and up.role == "o" and up.user_id == user.id)
    |> Repo.all()
  end

  def setup_monitored_incident(service_id, is_up) do
    with %Service{} = service <- get_service(service_id) do
      if is_up do
        with %Incident{} = incident <- get_monitored_incident(service_id) do
          close_monitored_incident(service, incident)
        end
      else
        if service.monitoring_enabled && service.auto_incident do
          insert_monitored_incident(service)
        end
      end
    end
  end

  def insert_monitored_incident(service) do
    Incident.monitored_changeset(service)
    |> Repo.insert()
    update_service_statuses(service.status_page_id)
  end

  def close_monitored_incident(service, incident) do
    activity_type = Repo.get_by!(ActivityType, key: "resolved")
    IncidentActivity.changeset(%IncidentActivity{}, %{
      incident_id: incident.id,
      description: "Service is back up.",
      activity_type_id: activity_type.id
    })
    |> Repo.insert()

    change(incident, ends_at: Ecto.DateTime.utc) |> Repo.update
    update_service_statuses(service.status_page_id)
  end

  def get_service(service_id) do
    Repo.get(Service, service_id)
  end

  def delete_service!(%Service{} = service), do: service |> Repo.delete!

  def update_service_statuses(page_id) do
    services = Service |> where(status_page_id: ^page_id) |> Repo.all()
    statuses = get_statuses(page_id)
    for service <- services do
      service
      |> change(%{current_incident_type: statuses[service.id]})
      |> Repo.update
    end
  end

  # Incidents

  def get_monitored_incident(service_id) do
    from(i in Incident, join: s in assoc(i, :services),
      where: s.id == ^service_id and is_nil(i.ends_at) and i.monitored == true)
    |> Repo.all()
    |> List.first()
  end

  def get_incidents_history(status_page, n_days) do
    incidents = from(i in Incident, join: s in assoc(i, :services),
      where: s.status_page_id == ^status_page.id and
        i.starts_at >= ^Timex.shift(now(), days: -n_days-1) and
        i.starts_at < ^Timex.shift(now(), days: -1))
    |> Repo.all()
    |> Enum.map(&(Map.take(&1, [:title, :type, :starts_at, :ends_at])))

    incidents_seconds = incidents
    |> Enum.filter(&(&1.type == "a"))
    |> Enum.reduce(0, fn(i, acc) ->
      DateTime.diff(
      if(i.ends_at, do: DateTime.from_naive!(i.ends_at, "Etc/UTC"), else: DateTime.utc_now()),
        DateTime.from_naive!(i.starts_at, "Etc/UTC")
      ) end)
    uptime = Float.round(100 - ((incidents_seconds / 60 / 60 / 24) / (n_days / 100)), 4)
    {uptime, incidents}
  end

  def incident_status(incident) do
    from(a in IncidentActivity,
      join: t in assoc(a, :activity_type),
      select: [a, t],
      where: a.incident_id == ^incident.id,
      order_by: [desc: a.inserted_at],
      limit: 1)
    |> Repo.one
  end

  # Incident activities

  def close_incident_if_cecessary(incident_id, params, subdomain) do
    type = ActivityType |> Repo.get(params["activity_type_id"])
    if type.key == "resolved" do
      page = StatusPage |> where(subdomain: ^subdomain) |> Repo.one!
      change(%Incident{id: incident_id}, ends_at: Ecto.DateTime.utc) |> Repo.update
      update_service_statuses(page.id)
    end
  end
end
