Code.ensure_loaded Phoenix.Swoosh

defmodule StatushqWeb.StatusPageEmail do
  use Phoenix.Swoosh, view: StatushqWeb.EmailView, layout: {StatushqWeb.LayoutView, :email}
  alias Swoosh.Email

  def status_notification(page, activity, incident) do
    %Email{}
    |> from(Coherence.Config.email_from)
    |> to("messuti.edd@gmail.com")
    |> subject("[#{activity.activity_type.name}] #{String.capitalize(page.name)} Status Update")
    |> render_body("status_notification.html", %{page_name: page.name, activity: activity, incident: incident})
  end
end
