defmodule SpotMe.Playback do
  @moduledoc """
  The Playback context.
  """

  import Ecto.Query, warn: false
  alias SpotMe.Repo

  alias SpotMe.Playback.{Album, Artist, AlbumsArtist, ArtistsSong, Play, Song}

  @doc """
  Creates a play.

  ## Examples

      iex> create_play(%{field: value})
      {:ok, %Play{}}

      iex> create_play(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_play(attrs \\ %{}) do
    %Play{}
    |> Play.changeset(attrs)
    |> Repo.insert()
  end

  def list_recent_plays() do
    from(p in Play, order_by: [desc: p.played_at], select: p, limit: 80)
    |> Repo.all()
    |> Repo.preload(song: [:artists, :album])
  end

  def most_recent_play_time() do
    one_day_ago = DateTime.utc_now() |> DateTime.add(-1 * 24 * 60 * 60, :second)

    case from(p in Play,
           select: p.played_at,
           order_by: [desc: p.played_at],
           limit: 1
         )
         |> Repo.all() do
      [] -> one_day_ago
      results -> hd(results)
    end
    |> DateTime.to_unix()
  end

  def get_recent_plays(spotify_user_id) do
    from(p in Play,
      select: p,
      where: p.spotify_user_id == ^spotify_user_id,
      where: p.inserted_at > ^one_hour_ago(),
      order_by: [desc: p.inserted_at]
    )
    |> Repo.all()
  end

  def filter_duplicate_plays(plays) do
    {without_duplicates, _} =
      Enum.reduce(plays, {[], %{}}, fn %{song_id: song_id, played_at: played_at} = play,
                                       {play_list, song_id_played_map} ->
        acc_with_play = {[play | play_list], Map.put_new(song_id_played_map, song_id, played_at)}

        case Map.get(song_id_played_map, song_id) do
          nil ->
            acc_with_play

          existing_played_at ->
            case Play.is_duplicate_play?(existing_played_at, played_at) do
              true -> {play_list, song_id_played_map}
              false -> acc_with_play
            end
        end
      end)

    without_duplicates
  end

  def record_recent_playback(plays, user_id) do
    recent_plays = get_recent_plays(user_id)

    Enum.map(plays, fn play ->
      artists = Map.get(play, :artists)
      {:ok, album_id} = Map.get(play, :album) |> upsert_album()
      {:ok, %Song{id: song_id}} = Map.get(play, :song) |> upsert_song(album_id, artists)

      played_at = Map.get(play, :played_at)

      %{
        played_at: played_at,
        song_id: song_id,
        spotify_user_id: user_id
      }
    end)
    |> filter_duplicate_plays()
    |> Enum.each(fn play_data ->
      if not is_play_duplicate?(recent_plays, play_data) do
        create_play(play_data)
        |> handle_create_play_errors()
      end
    end)
  end

  defp is_play_duplicate?(nil, _), do: false

  defp is_play_duplicate?(existing_plays, %{
         played_at: new_track_played_at,
         song_id: new_track_song_id
       }) do
    Enum.any?(existing_plays, fn %Play{played_at: played_at, song_id: song_id} ->
      case song_id == new_track_song_id do
        false -> false
        true -> Play.is_duplicate_play?(new_track_played_at, played_at)
      end
    end)
  end

  def handle_create_play_errors(create_result) do
    case create_result do
      {:error, %Ecto.Changeset{errors: [played_at: _]}} ->
        nil

      {:error, err} ->
        Sentry.capture_message("play_save_failed", %{err: err})
        IO.puts("failed to create new play")
        IO.inspect(err)

      _ ->
        nil
    end
  end

  def upsert_album(nil), do: nil

  def upsert_album(album) do
    # upsert album data
    id = Map.get(album, "id")

    album_data = %{
      ext_spotify_id: id,
      images: %{data: Map.get(album, "images")},
      name: Map.get(album, "name"),
      type: Map.get(album, "type"),
      total_tracks: Map.get(album, "total_tracks")
    }

    {:ok, %Album{id: album_id}} =
      case Repo.get_by(Album, ext_spotify_id: id) do
        nil -> %Album{}
        album -> album
      end
      |> Album.changeset(album_data)
      |> Repo.insert_or_update()

    # upsert artists
    artists =
      Map.get(album, "artists")
      |> upsert_artists()

    # upsert many to many table
    upsert_album_artists(album_id, artists)

    {:ok, album_id}
  end

  def upsert_song(nil, _), do: nil

  def upsert_song(song, album_id, artists) do
    id = Map.get(song, :ext_id)

    song_data = %{
      ext_spotify_id: id,
      duration_ms: Map.get(song, :duration_ms),
      name: Map.get(song, :name),
      album_id: album_id
    }

    {:ok, %Song{id: song_id} = song} =
      case Repo.get_by(Song, ext_spotify_id: id) do
        nil -> %Song{}
        song -> song
      end
      |> Song.changeset(song_data)
      |> Repo.insert_or_update()

    artists_ids = upsert_artists(artists)

    upsert_song_artists(song_id, artists_ids)

    {:ok, song}
  end

  def upsert_artists(artists) do
    Enum.map(artists, fn artist ->
      ext_spotify_id = Map.get(artist, "id")

      artist_data = %{
        ext_spotify_id: ext_spotify_id,
        name: Map.get(artist, "name")
      }

      artist =
        case Repo.get_by(Artist, ext_spotify_id: ext_spotify_id) do
          nil -> %Artist{}
          artist -> artist
        end
        |> Artist.changeset(artist_data)
        |> Repo.insert_or_update()

      case artist do
        {:ok, %Artist{id: id}} ->
          id

        {:error, err} ->
          IO.puts("failed to upsert artist")
          IO.inspect(err)
          nil
      end
    end)
    |> Enum.filter(&(not is_nil(&1)))
  end

  def upsert_album_artists(album_id, artists) do
    Enum.each(artists, fn artist_id ->
      album_artist_data = %{
        album_id: album_id,
        artist_id: artist_id,
        type: "artist"
      }

      album_artist =
        case Repo.get_by(AlbumsArtist, artist_id: artist_id, album_id: album_id) do
          nil -> %AlbumsArtist{}
          album_artist -> album_artist
        end
        |> AlbumsArtist.changeset(album_artist_data)
        |> Repo.insert_or_update()

      case album_artist do
        {:error, err} ->
          IO.puts("failed to upsert album artist")
          IO.inspect(err)

        _ ->
          nil
      end
    end)
  end

  def upsert_song_artists(song_id, artists) do
    Enum.each(artists, fn artist_id ->
      artist_song_data = %{
        song_id: song_id,
        artist_id: artist_id,
        type: "artist"
      }

      artists_song =
        case Repo.get_by(ArtistsSong, artist_id: artist_id, song_id: song_id) do
          nil -> %ArtistsSong{}
          artist_song -> artist_song
        end
        |> ArtistsSong.changeset(artist_song_data)
        |> Repo.insert_or_update()

      case artists_song do
        {:error, err} ->
          IO.puts("failed to upsert artists song")
          IO.inspect(err)

        _ ->
          nil
      end
    end)
  end

  def top_played_songs() do
    songs_query =
      from(p in Play,
        select: %{song_id: p.song_id, count: count(p.song_id)},
        where: p.inserted_at > ^two_weeks_ago(),
        group_by: p.song_id
      )

    from(s in Song,
      join: q in subquery(songs_query),
      on: s.id == q.song_id,
      select: %{name: s.name, count: q.count},
      order_by: [desc: q.count, desc: s.id],
      limit: 10
    )
    |> Repo.all()
  end

  def top_played_albums() do
    albums_query =
      from(p in Play,
        join: s in assoc(p, :song),
        select: %{album_id: s.album_id, sum: sum(s.duration_ms)},
        where: p.inserted_at > ^two_weeks_ago(),
        group_by: s.album_id
      )

    from(a in Album,
      join: q in subquery(albums_query),
      on: a.id == q.album_id,
      select: %{name: a.name, total_ms: q.sum / 1000},
      order_by: [desc: q.sum, desc: a.id],
      limit: 10
    )
    |> Repo.all()
  end

  def recent_song_totals() do
    from(p in Play,
      join: s in assoc(p, :song),
      select: %{count: count(p.id), sum: sum(s.duration_ms / 1000)},
      where: p.inserted_at > ^two_weeks_ago()
    )
    |> Repo.all()
  end

  def get_monthly_stats(b, e) do
    top_albums = top_albums_between_dates(b, e)
    top_artists = top_artists_between_dates(b, e)

    {count_not_played_last_month, count_played_last_month} = get_fresh_plays_for_month(b, e)

    {count_new_songs, count_old_songs} = get_new_plays_for_month(b, e)

    ms_played = get_minutes_played_for_month(b, e) || 0
    minutes_played = round(ms_played / (60 * 1000))

    total_played_last_month = count_not_played_last_month + count_played_last_month

    total_song_count = count_new_songs + count_old_songs

    percent_not_played_last_month =
      if total_played_last_month > 0 do
        round(
          count_not_played_last_month / total_played_last_month *
            100
        )
      else
        0
      end

    percent_not_played_before =
      if total_song_count > 0 do
        round(count_new_songs / total_song_count * 100)
      else
        0
      end

    %{
      albums: top_albums,
      minutes_played: minutes_played,
      artists: top_artists,
      percent_not_played_last_month: percent_not_played_last_month,
      percent_not_played_before: percent_not_played_before
    }
  end

  def top_albums_between_dates(start, finish) do
    from(p in Play,
      join: s in assoc(p, :song),
      join: a in assoc(s, :album),
      where: p.inserted_at > ^start,
      where: p.inserted_at < ^finish,
      group_by: a.id,
      select: {count(a.id), a, sum(s.duration_ms)},
      order_by: [desc: sum(s.duration_ms)],
      limit: 10
    )
    |> Repo.all()
  end

  def top_artists_between_dates(start, finish) do
    from(p in Play,
      join: s in assoc(p, :song),
      join: a in assoc(s, :artists),
      where: p.inserted_at > ^start,
      where: p.inserted_at < ^finish,
      group_by: a.id,
      select: {count(a.id), a, sum(s.duration_ms)},
      order_by: [desc: sum(s.duration_ms)],
      limit: 10
    )
    |> Repo.all()
  end

  def get_fresh_plays_for_month(start, finish) do
    beginning_of_previous_month =
      Date.add(start, -25) |> Date.beginning_of_month() |> DateTime.new!(~T[00:00:00])

    previous_month_subquery =
      from(p in Play,
        join: s in assoc(p, :song),
        where: p.inserted_at > ^beginning_of_previous_month,
        where: p.inserted_at < ^start,
        distinct: true,
        select: s.id
      )

    fresh =
      from(p in Play,
        join: s in assoc(p, :song),
        where: p.inserted_at > ^start,
        where: p.inserted_at < ^finish,
        where: s.id not in subquery(previous_month_subquery),
        select: count(p.id)
      )
      |> Repo.one()

    stale =
      from(p in Play,
        join: s in assoc(p, :song),
        where: p.inserted_at > ^start,
        where: p.inserted_at < ^finish,
        where: s.id in subquery(previous_month_subquery),
        select: count(p.id)
      )
      |> Repo.one()

    {fresh, stale}
  end

  def get_new_plays_for_month(start, finish) do
    new =
      from(p in Play,
        join: s in assoc(p, :song),
        where: p.inserted_at > ^start,
        where: p.inserted_at < ^finish,
        where: s.inserted_at > ^start,
        where: s.inserted_at < ^finish,
        select: count(p.id)
      )
      |> Repo.one()

    old =
      from(p in Play,
        join: s in assoc(p, :song),
        where: p.inserted_at > ^start,
        where: p.inserted_at < ^finish,
        where: s.inserted_at < ^start,
        select: count(p.id)
      )
      |> Repo.one()

    {new, old}
  end

  def get_minutes_played_for_month(start, finish) do
    from(p in Play,
      join: s in assoc(p, :song),
      where: p.inserted_at > ^start,
      where: p.inserted_at < ^finish,
      select: sum(s.duration_ms)
    )
    |> Repo.one()
  end

  defp two_weeks_ago do
    two_weeks = 14 * 24 * 60 * 60
    DateTime.add(DateTime.utc_now(), two_weeks * -1, :second)
  end

  defp one_hour_ago do
    one_hour = 60 * 60
    DateTime.add(DateTime.utc_now(), one_hour * -1, :second)
  end

  def get_random_albums do
    from(p in Play,
      join: s in assoc(p, :song),
      join: a in assoc(s, :album),
      group_by: [a.name, a.id],
      select: %{
        album: a,
        play_count: count(p.id),
        track_count: count(s.id, distinct: true)
      },
      having: count(p.id) > 60 and count(s.id, distinct: true) > 4,
      order_by: [desc: count(p.id)]
    )
    |> Repo.all()
    |> Enum.shuffle()
    |> Enum.take(6)
  end
end
