defmodule SpotMeWeb.PageController do
  use SpotMeWeb, :controller

  def index(conn, _params) do
    plays = SpotMe.TunesCacheServer.get_recent_plays()

    render(conn, "index.html", plays: plays)
  end
end
