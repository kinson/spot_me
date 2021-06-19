defmodule SpotMeWeb.PageController do
  use SpotMeWeb, :controller

  def index(conn, _params) do
    plays = SpotMe.TunesCacheServer.get_recent_plays()
    currently_playing = SpotMe.TunesCacheServer.get_currently_playing()

    render(conn, "index.html", plays: plays, currently_playing: currently_playing)
  end

  def queue_it(conn, _params) do
    render(conn, "queue.html")
  end
end
