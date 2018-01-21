use Mix.Config

# Do not print debug messages in production
config :logger, level: :info

config :statushq, StatushqWeb.Endpoint,
  http: [ip: {0,0,0,0}, port: System.get_env("PORT") || 4000],
  url: [host: "${URL_HOST}", port: "${URL_PORT}", scheme: "${URL_SCHEMA}"], # This is critical for ensuring web-sockets properly authorize.
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Mix.Project.config[:version],
  check_origin: false

config :statushq, StatushqWeb.Endpoint,
  secret_key_base: "${SECRET_KEY_BASE}"

# Configure your database
config :statushq, Statushq.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "${DB_USERNAME}",
  hostname: "${DB_HOSTNAME}",
  password: "${DB_PASSWORD}",
  database: "${DB_NAME}",
  pool_size: 20

mg_config = [
  adapter: Swoosh.Adapters.Mailgun,
  domain: "${MG_DOMAIN}",
  api_key: "${MG_API_KEY}",
]

config :statushq, [
  mailgun_domain: Keyword.get(mg_config, :domain),
  mailgun_api_key: Keyword.get(mg_config, :api_key)
]
config :statushq, StatushqWeb.Mailer, mg_config
config :coherence, StatushqWeb.Coherence.Mailer, mg_config

config :extwitter, :oauth, [
   consumer_key: "${TWITTER_CONSUMER_KEY}",
   consumer_secret: "${TWITTER_CONSUMER_SECRET}",
]

config :statushq, :sp_subdomains, "${SP_SUBDOMAINS}"
