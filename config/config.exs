# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :radio,
  ecto_repos: [Radio.Repo]

# Configures the endpoint
config :radio, RadioWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "LED0U83ogFn5FsFj9SgSps09WEl93GluGLn6YXT7anxOpvL2qF2y03t0uyRu+IpD",
  render_errors: [view: RadioWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Radio.PubSub,
  live_view: [signing_salt: "a6HywH4G"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  level: :info

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :radio,
  base_volume: System.get_env("PLEX_BASE_VOLUME") || "/volume2",
  mount_point: System.get_env("PLEX_MOUNTPOINT") || "/Volumes",
  plex_token: System.get_env("PLEX_TOKEN"),
  plex_endpoint:
    System.get_env("PLEX_BASE_URL") ||
      "http://192.168.86.23:32400",
  # :default
  # python3 -m sounddevice
  device_id: 6

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
