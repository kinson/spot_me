defmodule SpotMe.Services.StartPlay do
  alias SpotMe.Configs.Spotify

  def with_context_uri(album_uri, access_token) do
    base_url = Spotify.api_base_url()
    endpoint = Spotify.start_play_endpoint()

    headers = [Authorization: "Bearer #{access_token}", "Content-Type": "application/json"]

    url = base_url <> endpoint

    body =
      %{
        context_uri: album_uri
      }
      |> Jason.encode!()

    case HTTPoison.put(url, body, headers) do
      %HTTPoison.Response{status_code: 204} = resp -> {:ok, resp}
      resp -> {:error, resp}
    end
  end
end
