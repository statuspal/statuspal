# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :statushq, ecto_repos: [Statushq.Repo]

# Configures the endpoint
config :statushq, StatushqWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: StatushqWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: StatushqWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Statushq.Accounts.User,
  repo: Statushq.Repo,
  module: Statushq,
  web_module: StatushqWeb,
  router: StatushqWeb.Router,
  messages_backend: StatushqWeb.Coherence.Messages,
  layout: {StatushqWeb.Coherence.LayoutView, :app},
  logged_out_url: "/",
  logged_in_url: "/admin",
  email_from_name: "Statushq.co",
  email_from_email: "noreply@Statushq.co",
  opts: [:authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :confirmable, :registerable]
# %% End Coherence Configuration %%

config :arc, storage: Arc.Storage.Local

config :canary, repo: Statushq.Repo,
  unauthorized_handler: {StatushqWeb.ControllerHelpers, :handle_unauthorized},
  not_found_handler: {StatushqWeb.ControllerHelpers, :handle_not_found}

import_config "#{Mix.env}.exs"
