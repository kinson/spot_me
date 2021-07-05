defmodule SpotMeWeb.JsonView do
  use SpotMeWeb, :view

  def render("index.json", assigns) do
    %{songs: assigns.songs, albums: assigns.albums, totals: assigns.totals}
  end
end
