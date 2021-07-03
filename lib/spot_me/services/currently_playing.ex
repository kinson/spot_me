defmodule SpotMe.Services.CurrentlyPlaying do
  alias SpotMe.Configs.Spotify

  def get_currently_playing_tracks!(access_token) do
    case get_currently_playing_tracks(access_token) do
      {:ok, token} ->
        token

      {:error, _} ->
        raise """
        Failed to get currently playing track
        """
    end
  end

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
      {:ok, %{"item" => track, "currently_playing_type" => "track"}} ->
        {:ok, extract_response_data(track)}

      _ ->
        {:ok, nil}
    end
  end

  def extract_response_data(track) do
    get_play_data(track)
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
      |> Enum.sort()

    artists_names =
      Enum.map(artists, fn artist ->
        Map.get(artist, "name")
      end)
      |> Enum.join(", ")

    artist_id = hd(artists) |> Map.get("id")
    album_name = Map.get(album, "name")
    song_id = Map.get(play, "id")
    album_id = Map.get(album, "id")

    %{
      name: name,
      album_cover: album_cover,
      artists: artists_names,
      album_name: album_name,
      song_id: song_id,
      album_id: album_id,
      artist_id: artist_id
    }
  end
end
