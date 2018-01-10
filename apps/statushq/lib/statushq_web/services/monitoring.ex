defmodule StatushqWeb.Admin.Monitoring do
  alias Statushq.SPM
  require Logger

  def set_monitoring(service) do
    if service.monitoring_enabled, do: subscribe(service), else: unsubscribe(service)
  end

  def subscribe(service) do
    resp = GenServer.call(
      {StatushqMonitor.ApiServer, :"monitor@127.0.0.1"},
      [:subscribe, to_string(service.id), service.ping_url]
    )
    with {:ok, %{check: %{status: status}}} <- resp do
      is_up = if status != "pending", do: status == "up" # true|false|nil
      SPM.set_service_up(service, is_up)
    end
    Logger.info inspect(resp)
    resp
  end

  def unsubscribe(service) do
    resp = GenServer.cast(
      {StatushqMonitor.ApiServer, :"monitor@127.0.0.1"},
      [:unsubscribe, to_string(service.id)]
    )
    SPM.set_service_up(service, false)
    Logger.debug inspect(resp)
    resp
  end
end
