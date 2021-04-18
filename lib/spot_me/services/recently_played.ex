defmodule SpotMe.Services.RecentlyPlayed do
  alias SpotMe.Configs.Spotify

  def get_recently_played_tracks(access_token, after_ms) do
    base_url = Spotify.api_base_url()
    endpoint = Spotify.recently_played_endpoint()
    query = "?after=#{after_ms}&limit=50"

    headers = [Authorization: "Bearer #{access_token}"]
    url = base_url <> endpoint <> query

    HTTPoison.get(url, headers)
    |> parse_response()
  end

  defp parse_response({:error, err}), do: {:error, err}

  defp parse_response({:ok, response}) do
    body =
      Map.get(response, :body)
      |> Jason.decode!()

    {:ok, extract_response_data(body), extract_next_cursor(body)}
  end

  def extract_response_data(body) do
    items = Map.get(body, "items")

    IO.puts("Fetched #{Enum.count(items)} recently played tracks from Spotify")

    Enum.map(items, &get_play_data/1)
  end

  def get_play_data(play) do
    track = Map.get(play, "track")
    played_at = Map.get(play, "played_at")

    album = Map.get(track, "album")
    artists = Map.get(track, "artists")
    track_name = Map.get(track, "name")
    track_ext_id = Map.get(track, "id")
    duration_ms = Map.get(track, "duration_ms")

    %{
      played_at: played_at,
      song: %{
        name: track_name,
        ext_id: track_ext_id,
        duration_ms: duration_ms
      },
      artists: artists,
      album: album
    }
  end

  def extract_next_cursor(%{"cursors" => nil}), do: nil
  def extract_next_cursor(%{"cursors" => %{"after" => after_ms}}), do: after_ms
end
