import Config

config :banking_api,
  ecto_repos: [BankingApi.Repo],
  generators: [context_app: :banking_api, binary_id: true]

config :banking_api, BankingApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: BankingApiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: BankingApi.PubSub,
  live_view: [signing_salt: "xYHpZ7q+"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
