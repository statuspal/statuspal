use Mix.Config

required_env_vars = ["HOST", "PORT", "SECRET_KEY_BASE", "MG_DOMAIN", "MG_API_KEY",
  "TWITTER_CONSUMER_KEY", "TWITTER_CONSUMER_SECRET"]

Enum.each(required_env_vars, fn(e_var) ->
  if !System.get_env(e_var) || System.get_env(e_var) == "" do
    throw("Missing env variable #{e_var}, please provide in .env file "<>
          "(use .env_template as template)")
  end
end)

port = String.to_integer(System.get_env("PORT") || "4000")

config :statushq, StatushqWeb.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :statushq, StatushqWeb.Endpoint,
  http: [ip: {0,0,0,0}, port: port],
  url: [host: System.get_env("HOST"), port: port, scheme: "http"], # This is critical for ensuring web-sockets properly authorize.
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  version: Mix.Project.config[:version],
  root: ".",
  check_origin: false

# Configure your database
config :statushq, Statushq.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: "postgres",
  username: "postgres",
  password: "postgres",
  database: "statushq_prod",
  pool_size: 20

mg_config = %{
  adapter: Swoosh.Adapters.Mailgun,
  domain: System.get_env("MG_DOMAIN"),
  api_key: System.get_env("MG_API_KEY"),
}

config :statushq, mailgun_domain: mg_config.domain, mailgun_api_key: mg_config.api_key
config :statushq, StatushqWeb.Mailer, mg_config
config :coherence, StatushqWeb.Coherence.Mailer, mg_config

config :extwitter, :oauth, [
   consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
   consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
]
