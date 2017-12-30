Code.ensure_loaded Phoenix.Swoosh

defmodule StatushqWeb.StatusPageEmail do
  use Phoenix.Swoosh, view: StatushqWeb.EmailView, layout: {StatushqWeb.LayoutView, :email}
  alias Swoosh.Email
  alias StatushqWeb.MailGun

  def status_notification(page, activity, incident) do
    %Email{}
    |> from(Coherence.Config.email_from)
    |> to("page-#{page.id}@#{MailGun.domain()}")
    |> subject("[#{activity.activity_type.name}] #{String.capitalize(page.name)} Status Update")
    |> render_body("status_notification.html", %{page_name: page.name, activity: activity, incident: incident})
  end
end
