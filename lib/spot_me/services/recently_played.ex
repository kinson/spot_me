defmodule SpotMe.Services.RecentlyPlayed do
  alias SpotMe.Auth.TokenSet
  alias SpotMe.Configs.Spotify

  def get_recently_played_tracks(%TokenSet{access_token: access_token}, after_ms) do
    base_url = Spotify.api_base_url()
    endpoint = Spotify.recently_played_endpoint()
    # query = "?after=#{after_ms}&limit=50"
    query = "?limit=20"

    headers = [Authorization: "Bearer #{access_token}"]
    url = base_url <> endpoint <> query

    HTTPoison.get(url, headers)
    |> parse_response()
  end

  def get_recently_played_tracks(%TokenSet{} = ts) do
    after_seconds =
      DateTime.utc_now()
      |> DateTime.add(-9000, :second)
      |> DateTime.to_unix()

    after_ms = after_seconds * 1000
    get_recently_played_tracks(ts, after_ms)
  end

  defp parse_response({:error, err}), do: {:error, err}

  defp parse_response({:ok, response}) do
    {:ok,
     Map.get(response, :body)
     |> Jason.decode!()
     |> extract_response_data()}
  end

  def extract_response_data(body) do
    Map.get(body, "items")
    |> Enum.map(&get_play_data/1)
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
end
