# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :fyler, Fyler.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "Pqvd69So5nnIOu2JqQFgZcbD6nb9AImWl/6i4PqGxB1xXHpzlTWsQaNMbxxbFVNG",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Fyler.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :joken,
  secret_key: "123"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :fyler, :task_types,
  video: :ffmpeg,
  audio: :ffmpeg,
  pdf: :doc

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
