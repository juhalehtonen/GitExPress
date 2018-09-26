# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :gitexpress,
  namespace: GitExPress

# Configures the endpoint
config :gitexpress, GitExPressWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UbQ4lBuCkS5+IIamdA22pfDzpY3+T/U7l564M8E/AVTiuuHSFywtLo5A51+Zz8/2",
  render_errors: [view: GitExPressWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GitExPress.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
