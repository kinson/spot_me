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
    monthly_stats = CacheServer.fetch_object("monthly_stats", &get_monthly_stats/0, 60 * 20)
    render(conn, "top.html", monthly_stats: monthly_stats)
  end

  def get_monthly_stats() do
    {albums, _count} =
      Enum.map_reduce(1..14, Date.utc_today(), fn _x, acc ->
        beginning_of_month = Date.beginning_of_month(acc)
        end_of_month = Date.end_of_month(acc)

        b = DateTime.new!(beginning_of_month, ~T[00:00:00])
        e = DateTime.new!(end_of_month, ~T[23:59:59])

        top_albums = Playback.top_albums_between_dates(b, e)
        top_artists = Playback.top_artists_between_dates(b, e)

        {count_not_played_last_month, count_played_last_month} =
          Playback.get_fresh_plays_for_month(b, e) |> IO.inspect()

        {count_new_songs, count_old_songs} =
          Playback.get_new_plays_for_month(b, e) |> IO.inspect()

        percent_not_played_last_month =
          round(
            count_not_played_last_month / (count_not_played_last_month + count_played_last_month) *
              100
          )

        percent_not_played_before =
          round(count_new_songs / (count_new_songs + count_old_songs) * 100)

        {%{
           month: beginning_of_month.month,
           albums: top_albums,
           artists: top_artists,
           percent_not_played_last_month: percent_not_played_last_month,
           percent_not_played_before: percent_not_played_before
         }, Date.add(beginning_of_month, -25)}
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
