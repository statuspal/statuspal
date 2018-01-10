Code.ensure_loaded Phoenix.Swoosh

defmodule StatushqWeb.StatusPageEmail do
  use Phoenix.Swoosh, view: StatushqWeb.EmailView, layout: {StatushqWeb.LayoutView, :email}
  alias Swoosh.Email
  alias StatushqWeb.MailGun

  def status_notification(conn, page, activity, incident) do
    %Email{}
    |> from(Coherence.Config.email_from)
    |> to("page-#{page.id}@#{MailGun.domain()}")
    |> subject("[#{activity.activity_type.name}] #{page.name} status update")
    |> render_body("status_notification.html",
      %{conn: conn, page: page, activity: activity, incident: incident})
  end

  def service_status_notification(email_vars, status) do
    %Email{}
    |> from(Coherence.Config.email_from)
    |> to(Map.keys(email_vars))
    |> put_provider_option(:recipient_vars, email_vars)
    |> subject("[#{status}] %recipient.page_name% %recipient.service_name% service status update")
    |> render_body("service_status_notification.html", %{status: status})
  end
end
