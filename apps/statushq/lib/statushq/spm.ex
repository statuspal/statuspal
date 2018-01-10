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
  alias Statushq.SPM.{StatusPage, IncidentActivity, Incident, ActivityType,
                      Services.Service}

  # StatusPages

  def list_pages(user) do
    from(p in StatusPage,
      join: m in assoc(p, :users_status_pages),
      where: m.user_id == ^user.id, select: [p, m])
    |> Repo.all
  end

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

  def list_services(page), do: Service |> where(status_page_id: ^page.id) |> Repo.all

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

  def delete_service!(%Service{} = service), do: service |> Repo.delete!

  def update_service_statuses(page_id) do
    services = Service |> Repo.all(status_page_id: page_id)
    statuses = get_statuses(page_id)
    for service <- services do
      service
      |> change(%{current_incident_type: statuses[service.id]})
      |> Repo.update
    end
  end

  # Incidents

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
