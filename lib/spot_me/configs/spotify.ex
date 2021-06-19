defmodule SpotMe.Configs.Spotify do
  defp module_config() do
    Application.get_env(:spot_me, SpotMe.Configs)
  end

  defp from_config(atom) do
    module_config()
    |> Keyword.fetch!(atom)
  end

  def client_id() do
    from_config(:client_id) ||
      raise """
      environment variable SPOTIFY_CLIENT_ID is missing.
      Maybe you need to run "source .env"?
      """
  end

  def client_secret() do
    from_config(:client_secret) ||
      raise """
      environment variable SPOTIFY_CLIENT_SECRET is missing.
      Maybe you need to run "source .env"?
      """
  end

  def auth_base_url() do
    from_config(:auth_base_url)
  end

  def api_base_url() do
    from_config(:api_base_url)
  end

  def scopes() do
    from_config(:scopes)
  end

  def redirect_uri do
    from_config(:redirect_uri)
  end

  def authorize_endpoint do
    from_config(:authorize_endpoint)
  end

  def token_endpoint do
    from_config(:token_endpoint)
  end

  def profile_endpoint do
    from_config(:profile_endpoint)
  end

  def recently_played_endpoint do
    from_config(:recently_played_endpoint)
  end

  def currently_playing_endpoint do
    from_config(:currently_playing_endpoint)
  end

  def search_endpoint do
    from_config(:search_endpoint)
  end

  def start_play_endpoint do
    from_config(:start_play_endpoint)
  end

  def queue_track_endpoint do
    from_config(:queue_track_endpoint)
  end
end
