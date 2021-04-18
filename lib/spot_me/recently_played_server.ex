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
    IO.puts("fetching recently played tracks after #{after_ms}")
    users = SpotMe.Auth.get_users_and_live_tokens()

    Enum.each(users, fn {user_id, access_token} ->
      fetch_after(access_token, user_id, after_ms)
    end)

    %{after_ms: get_unix_time_ms()}
  end

  def fetch_recent_plays(_) do
    unix_time_ms = SpotMe.Playback.most_recent_play() |> seconds_to_ms()
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
        IO.puts("Fetching next page of tracks after #{next_cursor}")
        fetch_after(access_token, user_id, next_cursor)
    end
  end

  defp get_unix_time_ms(offset_s \\ 0) do
    after_seconds =
      DateTime.utc_now()
      |> DateTime.add(-1 * offset_s, :second)
      |> DateTime.to_unix()

    seconds_to_ms(after_seconds)
  end

  def seconds_to_ms(seconds), do: seconds * 1000
end
