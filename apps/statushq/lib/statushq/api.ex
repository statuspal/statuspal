defmodule Statushq.Api do
  use GenServer
  alias Statushq.SPM
  alias StatushqWeb.{StatusPageEmail, Mailer}
  require Logger

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def handle_call([:status_change, subscriber_ids, new_status], _from, state) do
    Logger.debug ":status_change #{inspect(subscriber_ids)} to #{new_status}"
    subscriber_ids
    |> Enum.map(&String.to_integer/1)
    |> SPM.set_services_up(new_status == "up")
    {:reply, :ok, state}
  end

  # GenServer.cast({Statushq.Api, :"statushq@127.0.0.1"}, [:notify_status, ["17", "23"], "down"])
  def handle_call([:notify_status, subscriber_ids, status], _from, state) do
    Logger.debug ":notify_status #{inspect(subscriber_ids)} to #{status}"

    subscriber_ids
    |> Enum.map(&String.to_integer/1)
    |> SPM.get_services_with_pages()
    |> Enum.map(fn(serv) -> {hd(serv.status_page.users).email, get_vars(serv)} end)
    |> Map.new()
    |> StatusPageEmail.service_status_notification(status)
    |> Mailer.deliver

    {:reply, :ok, state}
  end

  def get_vars(service) do
    page = service.status_page
    %{service_name: service.name, page_subdomain: page.subdomain, page_name: page.name}
  end
end
