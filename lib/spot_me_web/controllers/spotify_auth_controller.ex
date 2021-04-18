defmodule SpotMeWeb.SpotifyAuthController do
  use SpotMeWeb, :controller

  alias SpotMe.Auth.{SpotifyUser}
  alias SpotMe.Services

  def authenticate_with_spotify(conn, _params) do
    spotify_auth_link = SpotMe.Services.Auth.get_authorization_link()
    redirect(conn, external: spotify_auth_link)
  end

  def spotify_oauth_callback(conn, %{"code" => code}) do
    # get the auth code
    {:ok, tokens} = Services.Auth.fetch_tokens_with_authorization_code(code)
    profile = Services.Profile.get_profile_data(tokens)

    # create the profile
    {:ok, %SpotifyUser{id: user_id} = spotify_user} = SpotMe.Auth.upsert_spotify_user(profile)

    # create tokens
    tokens = Map.put(tokens, :spotify_user_id, user_id)
    {:ok, token_set} = SpotMe.Auth.upsert_token_set(tokens)

    {:ok, plays} = Services.RecentlyPlayed.get_recently_played_tracks(token_set)

    SpotMe.Playback.record_recent_playback(plays, spotify_user)

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
