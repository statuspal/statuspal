defmodule StatushqWeb.Admin.AuthController do
  use StatushqWeb, :controller

  alias Statushq.SPM.StatusPage

  def request(conn, %{"status_page_id" => status_page_id}) do
    token = ExTwitter.request_token(
      admin_auth_url(conn, :callback, status_page_id: status_page_id)
    )
    {:ok, authenticate_url} = ExTwitter.authenticate_url(token.oauth_token)
    redirect conn, external: authenticate_url
  end

  def callback(conn, %{"oauth_token" => oauth_token, "oauth_verifier" => oauth_verifier,
    "status_page_id" => status_page_id}) do

    {:ok, access_token} = ExTwitter.access_token(oauth_verifier, oauth_token)

    new_config = [
      access_token: access_token.oauth_token,
      access_token_secret: access_token.oauth_token_secret
    ]
    ExTwitter.configure(:process, Enum.concat(ExTwitter.Config.get_tuples, new_config))
    user_info = ExTwitter.verify_credentials()

    page = StatusPage |> Repo.get_by!(subdomain: status_page_id)
    changeset = StatusPage.twitter_oauth_changeset(page, %{
      twitter_screen_name: user_info.screen_name,
      twitter_oauth_token: access_token.oauth_token,
      twitter_oauth_token_secret: access_token.oauth_token_secret
    })
    {resp, _} = Repo.update(changeset)

    conn
    |> put_layout(false)
    |> render("callback.html", resp: resp, screen_name: user_info.screen_name)
  end

  def callback(conn, %{"denied" => _}) do
    render(conn, "callback.html", resp: "denied", screen_name: '')
  end
end
