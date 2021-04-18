defmodule SpotMe.RefreshTokensServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: RefreshTokensProcess)
  end

  @impl true
  def init(state) do
    IO.puts("STARTING TOKEN REFRESH INTERVAL")
    :timer.send_interval(60_000, :work)

    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    refresh_tokens()
    {:noreply, state}
  end

  def refresh_tokens do
    five_minutes_from_now =
      DateTime.utc_now()
      |> DateTime.add(60 * 5, :second)

    tokens = SpotMe.Auth.get_tokens_near_expiration(five_minutes_from_now)

    IO.puts "refreshing #{Enum.count(tokens)} tokens"

    Enum.each(tokens, fn token_set ->
      case SpotMe.Services.Auth.refresh_access_token(token_set) do
        {:ok, new_tokens} ->
          SpotMe.Auth.upsert_token_set(new_tokens)

        {:error, error} ->
          IO.puts("failed to refresh token for user")
          IO.inspect(error)
      end
    end)
  end
end
