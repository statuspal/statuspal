defmodule StatushqWeb.Admin.Notification do
  alias Statushq.Repo
  alias StatushqWeb.{StatusPageEmail, Mailer, StatusPageView}
  import WithPro
  require Logger

  # Send notification about an incident update
  def incident_update_notification(conn, opts, page, incident, activity) do
    incident = Repo.preload(incident, :services)
    activity = Repo.preload(activity, :activity_type)
    if opts["notify"] == "true" && Statushq.is_mailgun_configured?() do
      StatusPageEmail.status_notification(conn, page, activity, incident)
      |> Mailer.deliver
    end

    if opts["tweet"] == "true" && Statushq.is_twitter_configured?() do
      new_config = [
        access_token: page.twitter_oauth_token,
        access_token_secret: page.twitter_oauth_token_secret
      ]
      ExTwitter.configure(:process, Enum.concat(ExTwitter.Config.get_tuples, new_config))
      url = StatushqWeb.Router.Helpers.status_page_incident_url(conn, :show, page.subdomain, incident)
      tweet = "#{activity.activity_type.name}: #{incident.title}\n#{activity.description}"
      tweet = if String.length(tweet) > 116,
        do: String.slice(tweet, 0..114) <> "…", else: tweet

      try do
        ExTwitter.update("#{tweet} #{StatusPageView.sd_url(url, page)}")
      rescue
        error ->
          Logger.error inspect(error)
          with_pro do: StatushqProWeb.ErrorReporter.report(
            conn, :error, error, System.stacktrace(), %{catched: true}
          )
      end
    end
  end
end
