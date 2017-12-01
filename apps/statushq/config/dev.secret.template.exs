use Mix.Config

config :extwitter, :oauth, [
   consumer_key: "",
   consumer_secret: "",
]

mg_config = [
  adapter: Swoosh.Adapters.Mailgun,
  domain: "",
  api_key: "",
]

config :statushq, [
  mailgun_domain: Keyword.fetch(mg_config, :domain),
  mailgun_api_key: Keyword.fetch(mg_config, :api_key)
]
config :statushq, StatushqWeb.Mailer, mg_config
config :coherence, StatushqWeb.Coherence.Mailer, mg_config
