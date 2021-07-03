defmodule SpotMeWeb.PageController do
  use SpotMeWeb, :controller

  alias Fiat.CacheServer

  alias SpotMe.{Auth, Services, Playback}

  def index(conn, _params) do
    plays = CacheServer.fetch_object("recent", &get_recently_played/0, 120)
    currently_playing = Fiat.CacheServer.fetch_object("current", &get_currently_playing/0, 20)

    render(conn, "index.html", plays: plays, currently_playing: currently_playing)
  end

  def get_currently_playing() do
    Auth.get_the_token()
    |> Services.CurrentlyPlaying.get_currently_playing_tracks!()
  end

  def get_recently_played() do
    Playback.list_recent_plays()
    |> Playback.Play.get_display_list()
  end
end
