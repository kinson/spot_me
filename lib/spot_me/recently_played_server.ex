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
    IO.puts "fetching recently played tracks after #{after_ms}"
    users = SpotMe.Auth.get_users_and_live_tokens()

    Enum.map(users, fn {user_id, access_token} ->
      {:ok, plays} =
        SpotMe.Services.RecentlyPlayed.get_recently_played_tracks(access_token, after_ms)

      SpotMe.Playback.record_recent_playback(plays, user_id)
    end)

    %{after_ms: get_unix_time_ms()}
  end

  def fetch_recent_plays(_) do
    twelve_hours_in_s = 12 * 60 * 60
    unix_time = get_unix_time_ms(twelve_hours_in_s)
    fetch_recent_plays(%{ after_ms: unix_time})
  end

  defp get_unix_time_ms(offset_s \\ 0) do
    after_seconds =
      DateTime.utc_now()
      |> DateTime.add(-1 * offset_s, :second)
      |> DateTime.to_unix()

    after_seconds * 1000
  end
end
