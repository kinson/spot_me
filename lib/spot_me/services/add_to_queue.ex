defmodule SpotMe.Services.AddToQueue do
  alias SpotMe.Configs.Spotify

  def with_context_uri(album_uri, access_token) do
    base_url = Spotify.api_base_url()
    endpoint = Spotify.queue_track_endpoint()

    headers = [Authorization: "Bearer #{access_token}"]
    query = "?uri=#{album_uri}"

    url = base_url <> endpoint <> query

    case HTTPoison.post(url, "", headers) |> IO.inspect() do
      %HTTPoison.Response{status_code: 204} = resp -> {:ok, resp}
      resp -> {:error, resp}
    end
  end
end
