defmodule SpotMeWeb.QueueLive.Index do
  @moduledoc false

  use SpotMeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("query-albums", %{"query" => query}, socket) do
    search_term = Map.get(query, "search")

    results = SpotMe.SearchCacheServer.search(search_term)

    {:noreply, assign(socket, :results, results)}
  end

  def handle_event("play-album", %{"uri" => uri}, socket) do
    token = get_access_token()

    case SpotMe.Services.StartPlay.with_context_uri(uri, token) do
      {:error, resp} -> send_to_sentry(resp)
      _ -> :ok
    end

    {:noreply, socket}
  end

  def handle_event("queue-album", %{"uri" => uri}, socket) do
    token = get_access_token()

    case SpotMe.Services.AddToQueue.with_context_uri(uri, token) do
      {:error, resp} -> send_to_sentry(resp)
      _ -> :ok
    end

    {:noreply, socket}
  end

  defp get_access_token() do
    {_, token} =
      SpotMe.Auth.get_users_and_live_tokens()
      |> hd()

    token
  end

  defp send_to_sentry(resp) do
    Sentry.Event.create_event(message: "Failed to play album", extra: resp)
    |> Sentry.send_event()
  end
end
