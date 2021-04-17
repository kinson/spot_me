defmodule SpotMeWeb.SpotifyAuthController do
  use SpotMeWeb, :controller

  alias SpotMe.Auth.{SpotifyUser}

  def authenticate_with_spotify(conn, _params) do
    spotify_auth_link = SpotMe.Services.Auth.get_authorization_link()
    redirect(conn, external: spotify_auth_link)
  end

  def spotify_oauth_callback(conn, %{"code" => code}) do
    # get the auth code
    {:ok, tokens} = SpotMe.Services.Auth.fetch_tokens_with_authorization_code(code)
    profile = SpotMe.Services.Profile.get_profile_data(tokens)

    # create the profile
    {:ok, %SpotifyUser{id: user_id}} = SpotMe.Auth.upsert_spotify_user(profile)

    # create tokens
    token_set = Map.put(tokens, :spotify_user_id, user_id)
    SpotMe.Auth.upsert_token_set(token_set)

    redirect(conn, to: "/")
  end

  def spotify_oauth_callback(conn, %{"error" => error}) do
    IO.puts("encountered error")
    IO.inspect(error)
    redirect(conn, to: "/")
  end

  def spotify_oauth_callback(conn, _) do
    redirect(conn, to: "/")
  end
end
