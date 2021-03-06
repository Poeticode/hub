# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hub,
  ecto_repos: [Hub.Repo]

# Configures the endpoint
config :hub, HubWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0txrmqu8lapXp8eJWt7i1kXBk8xGxrvQZn0SXxHRFzds4qa3SeiSv2JdboAE/iWx",
  render_errors: [view: HubWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Hub.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :arc,
  storage: Arc.Storage.Local

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
