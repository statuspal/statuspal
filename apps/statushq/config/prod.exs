use Mix.Config

# Do not print debug messages in production
config :logger, level: :info


config :statushq, StatushqWeb.Endpoint,
  http: [ip: {127,0,0,1}, port: System.get_env("PORT") || 4000],
  url: [host: "statuspal.io", port: 443, scheme: "https"], # This is critical for ensuring web-sockets properly authorize.
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Mix.Project.config[:version],
  check_origin: false

import_config "prod.secret.exs"
