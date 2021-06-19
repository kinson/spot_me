defmodule SpotMe.SearchCacheServer do
  use GenServer

  @table :search
  @clear_after :timer.hours(12)

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def search(search_term) do
    case :ets.lookup(@table, search_term) do
      [] -> search_and_cache(search_term)
      [{_, results} | _] -> results
    end
  end

  defp search_and_cache(search_term) do
    {_, token} =
      SpotMe.Auth.get_users_and_live_tokens()
      |> hd()

    {:ok, results} = SpotMe.Services.Search.search_albums(search_term, token)

    :ets.insert_new(@table, {search_term, results})

    results
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
