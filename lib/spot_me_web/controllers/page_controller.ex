defmodule SpotMeWeb.PageController do
  use SpotMeWeb, :controller

  def index(conn, _params) do
    plays =
      SpotMe.Playback.list_recent_plays()
      |> get_display_list()

    render(conn, "index.html", plays: plays)
  end

  defp get_display_list(plays) do
    Enum.reduce(plays, [nil], fn play, acc ->
      [top | rest] = acc

      case top do
        nil ->
          [{1, play.song}]

        {count, song} ->
          case song.album.id == play.song.album.id do
            true -> [{count + 1, song} | rest]
            false -> [{1, play.song} | acc]
          end
      end
    end)
    |> Enum.reverse()
  end
end
