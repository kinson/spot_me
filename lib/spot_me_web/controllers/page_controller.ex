defmodule SpotMeWeb.PageController do
  use SpotMeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
