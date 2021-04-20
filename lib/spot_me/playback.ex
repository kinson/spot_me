defmodule SpotMe.Playback do
  @moduledoc """
  The Playback context.
  """

  import Ecto.Query, warn: false
  alias SpotMe.Repo

  alias SpotMe.Playback.Play

  @doc """
  Returns the list of plays.

  ## Examples

      iex> list_plays()
      [%Play{}, ...]

  """
  def list_plays do
    Repo.all(Play)
  end

  def list_recent_plays() do
    from(p in Play, order_by: [desc: p.played_at], select: p, limit: 100)
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

  def get_most_recent_play(spotify_user_id) do
    case from(p in Play,
           select: p,
           where: p.spotify_user_id == ^spotify_user_id,
           order_by: [desc: p.inserted_at],
           limit: 1
         )
         |> Repo.all() do
      [] -> nil
      plays -> hd(plays)
    end
  end

  @doc """
  Gets a single play.

  Raises `Ecto.NoResultsError` if the Play does not exist.

  ## Examples

      iex> get_play!(123)
      %Play{}

      iex> get_play!(456)
      ** (Ecto.NoResultsError)

  """
  def get_play!(id), do: Repo.get!(Play, id)

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

  @doc """
  Updates a play.

  ## Examples

      iex> update_play(play, %{field: new_value})
      {:ok, %Play{}}

      iex> update_play(play, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_play(%Play{} = play, attrs) do
    play
    |> Play.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a play.

  ## Examples

      iex> delete_play(play)
      {:ok, %Play{}}

      iex> delete_play(play)
      {:error, %Ecto.Changeset{}}

  """
  def delete_play(%Play{} = play) do
    Repo.delete(play)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking play changes.

  ## Examples

      iex> change_play(play)
      %Ecto.Changeset{data: %Play{}}

  """
  def change_play(%Play{} = play, attrs \\ %{}) do
    Play.changeset(play, attrs)
  end

  alias SpotMe.Playback.Song

  @doc """
  Returns the list of songs.

  ## Examples

      iex> list_songs()
      [%Song{}, ...]

  """
  def list_songs do
    Repo.all(Song)
  end

  @doc """
  Gets a single song.

  Raises `Ecto.NoResultsError` if the Song does not exist.

  ## Examples

      iex> get_song!(123)
      %Song{}

      iex> get_song!(456)
      ** (Ecto.NoResultsError)

  """
  def get_song!(id), do: Repo.get!(Song, id)

  @doc """
  Creates a song.

  ## Examples

      iex> create_song(%{field: value})
      {:ok, %Song{}}

      iex> create_song(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_song(attrs \\ %{}) do
    %Song{}
    |> Song.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a song.

  ## Examples

      iex> update_song(song, %{field: new_value})
      {:ok, %Song{}}

      iex> update_song(song, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_song(%Song{} = song, attrs) do
    song
    |> Song.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a song.

  ## Examples

      iex> delete_song(song)
      {:ok, %Song{}}

      iex> delete_song(song)
      {:error, %Ecto.Changeset{}}

  """
  def delete_song(%Song{} = song) do
    Repo.delete(song)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking song changes.

  ## Examples

      iex> change_song(song)
      %Ecto.Changeset{data: %Song{}}

  """
  def change_song(%Song{} = song, attrs \\ %{}) do
    Song.changeset(song, attrs)
  end

  alias SpotMe.Playback.Artist

  @doc """
  Returns the list of artists.

  ## Examples

      iex> list_artists()
      [%Artist{}, ...]

  """
  def list_artists do
    Repo.all(Artist)
  end

  @doc """
  Gets a single artist.

  Raises `Ecto.NoResultsError` if the Artist does not exist.

  ## Examples

      iex> get_artist!(123)
      %Artist{}

      iex> get_artist!(456)
      ** (Ecto.NoResultsError)

  """
  def get_artist!(id), do: Repo.get!(Artist, id)

  @doc """
  Creates a artist.

  ## Examples

      iex> create_artist(%{field: value})
      {:ok, %Artist{}}

      iex> create_artist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_artist(attrs \\ %{}) do
    %Artist{}
    |> Artist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a artist.

  ## Examples

      iex> update_artist(artist, %{field: new_value})
      {:ok, %Artist{}}

      iex> update_artist(artist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_artist(%Artist{} = artist, attrs) do
    artist
    |> Artist.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a artist.

  ## Examples

      iex> delete_artist(artist)
      {:ok, %Artist{}}

      iex> delete_artist(artist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_artist(%Artist{} = artist) do
    Repo.delete(artist)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking artist changes.

  ## Examples

      iex> change_artist(artist)
      %Ecto.Changeset{data: %Artist{}}

  """
  def change_artist(%Artist{} = artist, attrs \\ %{}) do
    Artist.changeset(artist, attrs)
  end

  alias SpotMe.Playback.Album

  @doc """
  Returns the list of albums.

  ## Examples

      iex> list_albums()
      [%Album{}, ...]

  """
  def list_albums do
    Repo.all(Album)
  end

  @doc """
  Gets a single album.

  Raises `Ecto.NoResultsError` if the Album does not exist.

  ## Examples

      iex> get_album!(123)
      %Album{}

      iex> get_album!(456)
      ** (Ecto.NoResultsError)

  """
  def get_album!(id), do: Repo.get!(Album, id)

  @doc """
  Creates a album.

  ## Examples

      iex> create_album(%{field: value})
      {:ok, %Album{}}

      iex> create_album(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_album(attrs \\ %{}) do
    %Album{}
    |> Album.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a album.

  ## Examples

      iex> update_album(album, %{field: new_value})
      {:ok, %Album{}}

      iex> update_album(album, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_album(%Album{} = album, attrs) do
    album
    |> Album.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a album.

  ## Examples

      iex> delete_album(album)
      {:ok, %Album{}}

      iex> delete_album(album)
      {:error, %Ecto.Changeset{}}

  """
  def delete_album(%Album{} = album) do
    Repo.delete(album)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking album changes.

  ## Examples

      iex> change_album(album)
      %Ecto.Changeset{data: %Album{}}

  """
  def change_album(%Album{} = album, attrs \\ %{}) do
    Album.changeset(album, attrs)
  end

  alias SpotMe.Playback.ArtistsSong

  @doc """
  Returns the list of artists_songs.

  ## Examples

      iex> list_artists_songs()
      [%ArtistsSong{}, ...]

  """
  def list_artists_songs do
    Repo.all(ArtistsSong)
  end

  @doc """
  Gets a single artists_song.

  Raises `Ecto.NoResultsError` if the Artists song does not exist.

  ## Examples

      iex> get_artists_song!(123)
      %ArtistsSong{}

      iex> get_artists_song!(456)
      ** (Ecto.NoResultsError)

  """
  def get_artists_song!(id), do: Repo.get!(ArtistsSong, id)

  @doc """
  Creates a artists_song.

  ## Examples

      iex> create_artists_song(%{field: value})
      {:ok, %ArtistsSong{}}

      iex> create_artists_song(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_artists_song(attrs \\ %{}) do
    %ArtistsSong{}
    |> ArtistsSong.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a artists_song.

  ## Examples

      iex> update_artists_song(artists_song, %{field: new_value})
      {:ok, %ArtistsSong{}}

      iex> update_artists_song(artists_song, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_artists_song(%ArtistsSong{} = artists_song, attrs) do
    artists_song
    |> ArtistsSong.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a artists_song.

  ## Examples

      iex> delete_artists_song(artists_song)
      {:ok, %ArtistsSong{}}

      iex> delete_artists_song(artists_song)
      {:error, %Ecto.Changeset{}}

  """
  def delete_artists_song(%ArtistsSong{} = artists_song) do
    Repo.delete(artists_song)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking artists_song changes.

  ## Examples

      iex> change_artists_song(artists_song)
      %Ecto.Changeset{data: %ArtistsSong{}}

  """
  def change_artists_song(%ArtistsSong{} = artists_song, attrs \\ %{}) do
    ArtistsSong.changeset(artists_song, attrs)
  end

  alias SpotMe.Playback.AlbumsArtist

  @doc """
  Returns the list of albums_artists.

  ## Examples

      iex> list_albums_artists()
      [%AlbumsArtist{}, ...]

  """
  def list_albums_artists do
    Repo.all(AlbumsArtist)
  end

  @doc """
  Gets a single albums_artist.

  Raises `Ecto.NoResultsError` if the Albums artist does not exist.

  ## Examples

      iex> get_albums_artist!(123)
      %AlbumsArtist{}

      iex> get_albums_artist!(456)
      ** (Ecto.NoResultsError)

  """
  def get_albums_artist!(id), do: Repo.get!(AlbumsArtist, id)

  @doc """
  Creates a albums_artist.

  ## Examples

      iex> create_albums_artist(%{field: value})
      {:ok, %AlbumsArtist{}}

      iex> create_albums_artist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_albums_artist(attrs \\ %{}) do
    %AlbumsArtist{}
    |> AlbumsArtist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a albums_artist.

  ## Examples

      iex> update_albums_artist(albums_artist, %{field: new_value})
      {:ok, %AlbumsArtist{}}

      iex> update_albums_artist(albums_artist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_albums_artist(%AlbumsArtist{} = albums_artist, attrs) do
    albums_artist
    |> AlbumsArtist.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a albums_artist.

  ## Examples

      iex> delete_albums_artist(albums_artist)
      {:ok, %AlbumsArtist{}}

      iex> delete_albums_artist(albums_artist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_albums_artist(%AlbumsArtist{} = albums_artist) do
    Repo.delete(albums_artist)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking albums_artist changes.

  ## Examples

      iex> change_albums_artist(albums_artist)
      %Ecto.Changeset{data: %AlbumsArtist{}}

  """
  def change_albums_artist(%AlbumsArtist{} = albums_artist, attrs \\ %{}) do
    AlbumsArtist.changeset(albums_artist, attrs)
  end

  def filter_duplicate_plays(plays) do
    {without_duplicates, _} = Enum.reduce(plays, {[], %{}}, fn %{song_id: song_id, played_at: played_at} = play,
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
    most_recent_play = get_most_recent_play(user_id)

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
      if not is_play_duplicate?(most_recent_play, play_data) do
        create_play(play_data)
        |> handle_create_play_errors()
      end
    end)
  end

  defp is_play_duplicate?(nil, _), do: false

  defp is_play_duplicate?(%Play{played_at: played_at, song_id: song_id}, %{
         played_at: new_track_played_at,
         song_id: new_track_song_id
       }) do
    case song_id == new_track_song_id do
      false -> false
      true -> Play.is_duplicate_play?(new_track_played_at, played_at)
    end
  end

  def handle_create_play_errors(create_result) do
    case create_result do
      {:error, %Ecto.Changeset{errors: [played_at: _]}} ->
        nil

      {:error, err} ->
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
end
