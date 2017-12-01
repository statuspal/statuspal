Code.ensure_loaded Phoenix.Swoosh

defmodule StatushqWeb.UserStatusPageEmail do
  use Phoenix.Swoosh, view: StatushqWeb.EmailView, layout: {StatushqWeb.LayoutView, :email}
  alias Swoosh.Email
  alias Coherence.Config

  def invite(membership, url, page) do
    %Email{}
    |> from(Config.email_from)
    |> to(membership.email)
    |> subject("You received an invitation to collaborate in a status page!")
    |> render_body("invite.html", %{url: url, page: page})
  end
end
