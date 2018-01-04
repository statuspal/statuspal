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
end
