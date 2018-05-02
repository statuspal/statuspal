use Mix.Config

config :statushq, StatushqWeb.Endpoint,
  secret_key_base: "dev-e2qMFb9QRXSrPAV1YScOW1BKg/C6Q669NGj/9C/tnFPNbHrVL4MTg1X2cLIm"

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :statushq, StatushqWeb.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    npm: ["run", "watch", cd: Path.expand("../", __DIR__)],
  ]


# Watch static and templates for browser reloading.
config :statushq, StatushqWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :statushq, Statushq.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "statushq_dev",
  hostname: "localhost",
  pool_size: 10

config :statushq, monitor_host: "127.0.0.1"

import_config "dev.secret.exs"
