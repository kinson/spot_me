defmodule SpotMe.Configs.Spotify do
  defp module_config() do
    Application.get_env(:spot_me, SpotMe.Configs)
  end

  def client_id() do
    module_config()
    |> Keyword.fetch!(:client_id)
  end

  def client_secret() do
    module_config()
    |> Keyword.fetch!(:client_secret)
  end

  def auth_base_url() do
    module_config()
    |> Keyword.fetch!(:auth_base_url)
  end

  def api_base_url() do
    module_config()
    |> Keyword.fetch!(:api_base_url)
  end

  def scopes() do
    module_config()
    |> Keyword.fetch!(:scopes)
  end

  def redirect_uri do
    module_config()
    |> Keyword.fetch!(:redirect_uri)
  end

  def authorize_endpoint do
    module_config()
    |> Keyword.fetch!(:authorize_endpoint)
  end

  def token_endpoint do
    module_config()
    |> Keyword.fetch!(:token_endpoint)
  end

  def profile_endpoint do
    module_config()
    |> Keyword.fetch!(:profile_endpoint)
  end
end
