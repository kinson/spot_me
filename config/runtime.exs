import Config

config :spot_me, SpotMe.Configs,
  client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  client_secret: System.get_env("SPOTIFY_CLIENT_SECRET")

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :spot_me, SpotMe.Repo,
    ssl: false,
    url: database_url,
    socket_options: [:inet6],
    pool_size: 8,
    queue_target: 500,
    queue_interval: 5000

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :spot_me, SpotMeWeb.Endpoint,
    http: [
      port: String.to_integer(System.get_env("PORT") || "5000"),
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base

  config :sentry,
    dsn: System.get_env("SENTRY_DSN")
end
