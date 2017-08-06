# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :dots, DotsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XNMQOK6aFT1ASFDAWWC4PLFqkBE0j+/NlEEGf/UErPMUOc3k+2P7vlH+ExAmMOJR",
  render_errors: [view: DotsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Dots.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
