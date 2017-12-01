use Mix.Config

config :statushq, StatushqWeb.Endpoint,
  secret_key_base: "test-dHgqaLopISja4W4fzsCIc+9WetlfMAYOKCzaA7y4i+7+lZDq+5+dBOhPIb/"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :statushq, StatushqWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :statushq, Statushq.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "statushq_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :statushq, StatushqWeb.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  domain: "",
  api_key: ""
