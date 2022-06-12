defmodule SpotMeWeb.PageController do
  use SpotMeWeb, :controller

  alias Fiat.CacheServer

  alias SpotMe.{Auth, Services, Playback}

  def index(conn, _params) do
    plays = CacheServer.fetch_object("recent", &get_recently_played/0, 120)
    currently_playing = Fiat.CacheServer.fetch_object("current", &get_currently_playing/0, 20)
    render(conn, "index.html", plays: plays, currently_playing: currently_playing)
  end

  def top(conn, _params) do
    albums = get_top_albums()
    render(conn, "top.html", top_albums: albums)
  end

  def get_top_albums() do
    beginning_of_month = Date.utc_today() |> Date.beginning_of_month()

    {albums, _count} =
      Enum.map_reduce(1..5, Date.utc_today(), fn _x, acc ->
        beginning_of_month = Date.beginning_of_month(acc)
        end_of_month = Date.end_of_month(acc)

        midnight = ~T[00:00:00]
        b = DateTime.new!(beginning_of_month, ~T[00:00:00])
        e = DateTime.new!(end_of_month, ~T[23:59:59])

        {{beginning_of_month.month, Playback.top_albums_between_dates(b, e)},
         Date.add(beginning_of_month, -25)}
      end)

    albums
  end

  def get_currently_playing() do
    Auth.get_the_token()
    |> Services.CurrentlyPlaying.get_currently_playing_tracks!()
  end

  def get_recently_played() do
    Playback.list_recent_plays()
    |> Playback.Play.get_display_list()
  end

  def stats(conn, _params) do
    recent_songs = Playback.top_played_songs()
    recent_albums = Playback.top_played_albums()
    song_totals = Playback.recent_song_totals()

    conn
    |> put_view(SpotMeWeb.JsonView)
    |> render("index.json", songs: recent_songs, albums: recent_albums, totals: song_totals)
  end
end
