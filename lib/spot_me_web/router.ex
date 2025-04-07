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
    get "/random", PageController, :random_album

    get "/stats", PageController, :stats

    get "/spotify/auth", SpotifyAuthController, :authenticate_with_spotify
    get "/spotify/auth/callback", SpotifyAuthController, :spotify_oauth_callback
  end
end
