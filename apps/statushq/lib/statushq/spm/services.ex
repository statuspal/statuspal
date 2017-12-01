defmodule Statushq.SPM.Services do
  import Ecto.Query, warn: false
  alias Statushq.Repo
  alias Statushq.SPM.Services.Service

  def get_statuses(page_id) do
    now = DateTime.utc_now
    from(s in Service,
      join: i in assoc(s, :incidents),
      group_by: [s.id, i.type],
      select: [s, count(i.type), i.type],
      where: ^now >= i.starts_at and
        (i.ends_at > ^now or is_nil(i.ends_at)) and
        s.status_page_id == ^page_id)
    |> Repo.all
    |> get_statuses(%{})
  end

  def get_statuses([], statuses), do: statuses

  def get_statuses(services, statuses) do
    [serv, _, type] = hd(services)
    new_status = set_status(statuses[serv.id], type)
    statuses = Map.merge(statuses, %{serv.id => new_status})
    get_statuses(tl(services), statuses)
  end

  def set_status(old_status = "i", _new_status = "s"), do: old_status
  def set_status(old_status = "a", _new_status), do: old_status
  def set_status(_old_status, new_status), do: new_status
end
