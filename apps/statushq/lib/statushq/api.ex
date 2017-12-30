defmodule Statushq.Api do
  use GenServer
  alias Statushq.SPM

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def handle_cast([:status_change, subscriber_ids, new_status], state) do
    IO.puts ":status_change #{inspect(subscriber_ids)} to #{new_status}"
    subscriber_ids
    |> Enum.map(&String.to_integer/1)
    |> SPM.set_services_up(new_status == "up")
    {:noreply, state}
  end

  def handle_cast([:notify_status, subscriber_ids], state) do
    IO.puts ":notify_status #{inspect(subscriber_ids)}"
    {:noreply, state}
  end
end
