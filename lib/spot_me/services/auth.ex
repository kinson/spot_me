defmodule SpotMe.Services.Auth do
  alias SpotMe.Configs.Spotify
  alias SpotMe.Auth.TokenSet

  def get_authorization_link() do
    # return the link to send the user to auth
    client_id = Spotify.client_id()

    scope = Spotify.scopes()
    redirect_uri = Spotify.redirect_uri()

    base_url = Spotify.auth_base_url()
    authorize_endpoint = Spotify.authorize_endpoint()

    "#{base_url}#{authorize_endpoint}?client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{
      scope
    }&response_type=code"
  end

  def fetch_tokens_with_authorization_code(code) do
    # get the initial token set from spotify
    client_id = Spotify.client_id()
    client_secret = Spotify.client_secret()

    grant_type = "authorization_code"
    redirect_uri = Spotify.redirect_uri()

    base_url = Spotify.auth_base_url()
    token_endpoint = Spotify.token_endpoint()

    url = "#{base_url}#{token_endpoint}"

    body = [
      code: code,
      grant_type: grant_type,
      redirect_uri: redirect_uri,
      client_id: client_id,
      client_secret: client_secret
    ]

    HTTPoison.post(url, {:form, body})
    |> parse_token_response()
  end

  def refresh_access_token(%TokenSet{
        refresh_token: refresh_token,
        spotify_user_id: spotify_user_id
      }) do
    client_id = Spotify.client_id()
    client_secret = Spotify.client_secret()

    grant_type = "refresh_token"

    base_url = Spotify.auth_base_url()
    token_endpoint = Spotify.token_endpoint()

    url = "#{base_url}#{token_endpoint}"

    body = [
      refresh_token: refresh_token,
      grant_type: grant_type,
      client_id: client_id,
      client_secret: client_secret
    ]

    HTTPoison.post(url, {:form, body})
    |> parse_refresh_response(spotify_user_id)
  end

  defp parse_token_response({:error, err}), do: {:error, err}

  defp parse_token_response({:ok, response}) do
    %{
      "access_token" => access_token,
      "expires_in" => expires_in,
      "refresh_token" => refresh_token,
      "scope" => scope,
      "token_type" => token_type
    } =
      Map.get(response, :body)
      |> Jason.decode!()

    expires_at = DateTime.add(DateTime.utc_now(), expires_in, :second)

    {:ok,
     %{
       access_token: access_token,
       expires_in: expires_in,
       expires_at: expires_at,
       refresh_token: refresh_token,
       scope: scope,
       token_type: token_type
     }}
  end

  defp parse_refresh_response({:error, err}, _), do: {:error, err}

  defp parse_refresh_response({:ok, response}, spotify_user_id) do
    %{
      "access_token" => access_token,
      "token_type" => token_type,
      "scope" => scope,
      "expires_in" => expires_in
    } =
      Map.get(response, :body)
      |> Jason.decode!()

    expires_at = DateTime.add(DateTime.utc_now(), expires_in, :second)

    {:ok,
     %{
       spotify_user_id: spotify_user_id,
       access_token: access_token,
       expires_in: expires_in,
       expires_at: expires_at,
       scope: scope,
       token_type: token_type
     }}
  end
end
