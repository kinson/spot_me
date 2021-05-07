defmodule SpotMe.TunesCacheServer do
  use GenServer

  @table :tunes
  @clear_after :timer.seconds(30)

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get_currently_playing() do
    case :ets.lookup(@table, :current) do
      [] -> requery_and_cache(:current)
      [{:current, result} | _] -> result
    end
  end

  def get_recent_plays() do
    case :ets.lookup(@table, :recent) do
      [] -> requery_and_cache(:recent)
      [{:recent, result} | _] -> result
    end
  end

  defp requery_and_cache(:recent) do
    plays =
      SpotMe.Playback.list_recent_plays()
      |> SpotMe.Playback.Play.get_display_list()

    :ets.insert_new(@table, {:recent, plays})

    plays
  end

  defp requery_and_cache(:current) do
    {_, token} =
      SpotMe.Auth.get_users_and_live_tokens()
      |> hd()

    {:ok, track} = SpotMe.Services.CurrentlyPlaying.get_currently_playing_tracks(token)

    :ets.insert_new(@table, {:current, track})

    track
  end

  @impl true
  def init(state) do
    :ets.new(@table, [
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])

    schedule_clear()
    {:ok, state}
  end

  @impl true
  def handle_info(:clear, state) do
    :ets.delete_all_objects(@table)
    schedule_clear()
    {:noreply, state}
  end

  defp schedule_clear() do
    Process.send_after(self(), :clear, @clear_after)
  end
end
