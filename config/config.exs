# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

spotify_client_id = System.get_env("SPOTIFY_CLIENT_ID")

spotify_client_secret = System.get_env("SPOTIFY_CLIENT_SECRET")

sentry_dsn = System.get_env("SENTRY_DSN")

config :spot_me,
  ecto_repos: [SpotMe.Repo]

# Configures the endpoint
config :spot_me, SpotMeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JFyBxXkHCEelXXPJ5LfUcUdKmQSUCf36oHfTIcLQJ2vPfdEn0qyVJo0Yb/5WrQpB",
  render_errors: [view: SpotMeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SpotMe.PubSub,
  live_view: [signing_salt: "9flJjHcJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :spot_me, SpotMe.Configs,
  auth_base_url: "https://accounts.spotify.com",
  api_base_url: "https://api.spotify.com/v1",
  authorize_endpoint: "/authorize",
  token_endpoint: "/api/token",
  profile_endpoint: "/me",
  recently_played_endpoint: "/me/player/recently-played",
  currently_playing_endpoint: "/me/player",
  scopes: "user-read-recently-played user-read-email user-read-playback-state",
  client_id: spotify_client_id,
  client_secret: spotify_client_secret

config :sentry,
  dsn: sentry_dsn,
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "production"
  },
  included_environments: [:prod]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
