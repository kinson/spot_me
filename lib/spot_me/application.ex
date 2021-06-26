defmodule SpotMe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SpotMe.Repo,
      # Start the Telemetry supervisor
      SpotMeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SpotMe.PubSub},
      # Start the Endpoint (http/https)
      SpotMeWeb.Endpoint,
      # Start a worker by calling: SpotMe.Worker.start_link(arg)
      # {SpotMe.Worker, arg}
      SpotMe.RefreshTokensServer,
      SpotMe.RecentlyPlayedServer,
      SpotMe.SearchCacheServer,
      SpotMe.TunesCacheServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SpotMe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SpotMeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
