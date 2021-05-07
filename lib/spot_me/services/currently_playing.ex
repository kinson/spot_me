defmodule SpotMe.Services.CurrentlyPlaying do
  alias SpotMe.Configs.Spotify

  def get_currently_playing_tracks(access_token) do
    base_url = Spotify.api_base_url()
    endpoint = Spotify.currently_playing_endpoint()

    headers = [Authorization: "Bearer #{access_token}"]
    url = base_url <> endpoint

    HTTPoison.get(url, headers)
    |> parse_response()
  end

  defp parse_response({:error, err}), do: {:error, err}

  defp parse_response({:ok, response}) do
    case Map.get(response, :body) |> Jason.decode() do
      {:ok, body} -> {:ok, extract_response_data(body)}
      _ -> {:ok, nil}
    end
  end

  def extract_response_data(body) do
    play = Map.get(body, "item")

    get_play_data(play)
  end

  def get_play_data(play) do
    name = Map.get(play, "name")
    album = Map.get(play, "album")

    album_cover =
      Map.get(album, "images")
      |> Enum.at(1)
      |> Map.get("url")

    artists =
      Map.get(play, "artists")
      |> Enum.map(fn artist ->
        Map.get(artist, "name")
      end)
      |> Enum.join(", ")

    album_name = Map.get(album, "name")

    %{
      name: name,
      album_cover: album_cover,
      artists: artists,
      album_name: album_name
    }
  end
end
