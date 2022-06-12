defmodule SpotMeWeb.Router do
  use SpotMeWeb, :router

  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpotMeWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/top", PageController, :top

    get "/stats", PageController, :stats

    get "/spotify/auth", SpotifyAuthController, :authenticate_with_spotify
    get "/spotify/auth/callback", SpotifyAuthController, :spotify_oauth_callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", SpotMeWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  pipeline :dash do
    plug :basic_auth,
      username: "sam",
      password: Application.fetch_env!(:spot_me, :dash_pass)
  end

  if Mix.env() in [:dev, :prod] do
    import Phoenix.LiveDashboard.Router

    scope "/admin" do
      pipe_through [:browser, :dash]
      live_dashboard "/dashboard", metrics: SpotMeWeb.Telemetry, ecto_repos: [SpotMe.Repo]
    end
  end
end
