defmodule StatushqWeb.Admin.Notification do
  alias Statushq.Repo
  alias StatushqWeb.{StatusPageEmail, Mailer}

  # Send notification about an incident update
  def incident_update_notification(conn, opts, page, incident, activity) do
    incident = Repo.preload(incident, :services)
    activity = Repo.preload(activity, :activity_type)
    if opts["notify"] == "true" do
      StatusPageEmail.status_notification(page, activity, incident)
      |> Mailer.deliver
    end

    if opts["tweet"] == "true" do
      new_config = [
        access_token: page.twitter_oauth_token,
        access_token_secret: page.twitter_oauth_token_secret
      ]
      ExTwitter.configure(:process, Enum.concat(ExTwitter.Config.get_tuples, new_config))
      path = StatushqWeb.Router.Helpers.status_page_incident_path(conn, :show, page.subdomain, incident)
      tweet = "#{activity.activity_type.name}: #{incident.title}\n#{activity.description}"
      tweet = if String.length(tweet) > 116,
        do: String.slice(tweet, 0..114) <> "…", else: tweet

      ExTwitter.update("#{tweet} https://statuspal.io#{path}")
    end
  end
end
