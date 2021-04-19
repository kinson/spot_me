defmodule SpotMe.RecentlyPlayedServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: RecentlyPlayedProcess)
  end

  @impl true
  def init(state) do
    IO.puts("STARTING RECENTLY PLAYED POLLING INTERVAL")
    new_state = fetch_recent_plays(state)

    :timer.send_interval(1000_000, :work)

    {:ok, new_state}
  end

  @impl true
  def handle_info(:work, state) do
    new_state = fetch_recent_plays(state)
    {:noreply, new_state}
  end

  def fetch_recent_plays(%{after_ms: after_ms}) do
    # get users and access tokens
    IO.puts("fetching recently played tracks after #{human_readable_timestamp(after_ms)}")
    users = SpotMe.Auth.get_users_and_live_tokens()

    Enum.each(users, fn {user_id, access_token} ->
      fetch_after(access_token, user_id, after_ms)
    end)

    %{after_ms: most_recent_play_unix_ms()}
  end

  def fetch_recent_plays(_) do
    unix_time_ms = most_recent_play_unix_ms()
    fetch_recent_plays(%{after_ms: unix_time_ms})
  end

  def fetch_after(access_token, user_id, after_ms) do
    {:ok, plays, next_cursor} =
      SpotMe.Services.RecentlyPlayed.get_recently_played_tracks(access_token, after_ms)

    SpotMe.Playback.record_recent_playback(plays, user_id)

    case next_cursor do
      nil ->
        nil

      next_cursor ->
        IO.puts("Fetching next page of tracks after #{human_readable_timestamp(next_cursor)}")
        fetch_after(access_token, user_id, next_cursor)
    end
  end

  defp most_recent_play_unix_ms() do
    SpotMe.Playback.most_recent_play_time() |> seconds_to_ms()
  end

  def seconds_to_ms(seconds), do: seconds * 1000

  defp human_readable_timestamp(ms_string) when is_binary(ms_string) do
    String.to_integer(ms_string)
    |> human_readable_timestamp()
  end

  defp human_readable_timestamp(ms) do
    {:ok, dt} = DateTime.from_unix(ms, :millisecond)
    DateTime.add(dt, -1 * 60 * 60 * 6, :second)
  end
end
