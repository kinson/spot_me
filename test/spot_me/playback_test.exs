defmodule SpotMe.PlaybackTest do
  use SpotMe.DataCase

  alias SpotMe.Playback

  describe "plays" do
    alias SpotMe.Playback.Play

    @valid_attrs %{played_at: "some played_at", song_id: "some song_id"}
    @update_attrs %{played_at: "some updated played_at", song_id: "some updated song_id"}
    @invalid_attrs %{played_at: nil, song_id: nil}

    def play_fixture(attrs \\ %{}) do
      {:ok, play} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Playback.create_play()

      play
    end

    test "list_plays/0 returns all plays" do
      play = play_fixture()
      assert Playback.list_plays() == [play]
    end

    test "get_play!/1 returns the play with given id" do
      play = play_fixture()
      assert Playback.get_play!(play.id) == play
    end

    test "create_play/1 with valid data creates a play" do
      assert {:ok, %Play{} = play} = Playback.create_play(@valid_attrs)
      assert play.played_at == "some played_at"
      assert play.song_id == "some song_id"
    end

    test "create_play/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Playback.create_play(@invalid_attrs)
    end

    test "update_play/2 with valid data updates the play" do
      play = play_fixture()
      assert {:ok, %Play{} = play} = Playback.update_play(play, @update_attrs)
      assert play.played_at == "some updated played_at"
      assert play.song_id == "some updated song_id"
    end

    test "update_play/2 with invalid data returns error changeset" do
      play = play_fixture()
      assert {:error, %Ecto.Changeset{}} = Playback.update_play(play, @invalid_attrs)
      assert play == Playback.get_play!(play.id)
    end

    test "delete_play/1 deletes the play" do
      play = play_fixture()
      assert {:ok, %Play{}} = Playback.delete_play(play)
      assert_raise Ecto.NoResultsError, fn -> Playback.get_play!(play.id) end
    end

    test "change_play/1 returns a play changeset" do
      play = play_fixture()
      assert %Ecto.Changeset{} = Playback.change_play(play)
    end
  end

  describe "songs" do
    alias SpotMe.Playback.Song

    @valid_attrs %{
      album_id: "some album_id",
      duration_ms: "some duration_ms",
      ext_spotify_id: "some ext_spotify_id",
      name: "some name"
    }
    @update_attrs %{
      album_id: "some updated album_id",
      duration_ms: "some updated duration_ms",
      ext_spotify_id: "some updated ext_spotify_id",
      name: "some updated name"
    }
    @invalid_attrs %{album_id: nil, duration_ms: nil, ext_spotify_id: nil, name: nil}

    def song_fixture(attrs \\ %{}) do
      {:ok, song} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Playback.create_song()

      song
    end

    test "list_songs/0 returns all songs" do
      song = song_fixture()
      assert Playback.list_songs() == [song]
    end

    test "get_song!/1 returns the song with given id" do
      song = song_fixture()
      assert Playback.get_song!(song.id) == song
    end

    test "create_song/1 with valid data creates a song" do
      assert {:ok, %Song{} = song} = Playback.create_song(@valid_attrs)
      assert song.album_id == "some album_id"
      assert song.duration_ms == "some duration_ms"
      assert song.ext_spotify_id == "some ext_spotify_id"
      assert song.name == "some name"
    end

    test "create_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Playback.create_song(@invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = song_fixture()
      assert {:ok, %Song{} = song} = Playback.update_song(song, @update_attrs)
      assert song.album_id == "some updated album_id"
      assert song.duration_ms == "some updated duration_ms"
      assert song.ext_spotify_id == "some updated ext_spotify_id"
      assert song.name == "some updated name"
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      assert {:error, %Ecto.Changeset{}} = Playback.update_song(song, @invalid_attrs)
      assert song == Playback.get_song!(song.id)
    end

    test "delete_song/1 deletes the song" do
      song = song_fixture()
      assert {:ok, %Song{}} = Playback.delete_song(song)
      assert_raise Ecto.NoResultsError, fn -> Playback.get_song!(song.id) end
    end

    test "change_song/1 returns a song changeset" do
      song = song_fixture()
      assert %Ecto.Changeset{} = Playback.change_song(song)
    end
  end

  describe "artists" do
    alias SpotMe.Playback.Artist

    @valid_attrs %{ext_spotify_id: "some ext_spotify_id", name: "some name"}
    @update_attrs %{ext_spotify_id: "some updated ext_spotify_id", name: "some updated name"}
    @invalid_attrs %{ext_spotify_id: nil, name: nil}

    def artist_fixture(attrs \\ %{}) do
      {:ok, artist} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Playback.create_artist()

      artist
    end

    test "list_artists/0 returns all artists" do
      artist = artist_fixture()
      assert Playback.list_artists() == [artist]
    end

    test "get_artist!/1 returns the artist with given id" do
      artist = artist_fixture()
      assert Playback.get_artist!(artist.id) == artist
    end

    test "create_artist/1 with valid data creates a artist" do
      assert {:ok, %Artist{} = artist} = Playback.create_artist(@valid_attrs)
      assert artist.ext_spotify_id == "some ext_spotify_id"
      assert artist.name == "some name"
    end

    test "create_artist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Playback.create_artist(@invalid_attrs)
    end

    test "update_artist/2 with valid data updates the artist" do
      artist = artist_fixture()
      assert {:ok, %Artist{} = artist} = Playback.update_artist(artist, @update_attrs)
      assert artist.ext_spotify_id == "some updated ext_spotify_id"
      assert artist.name == "some updated name"
    end

    test "update_artist/2 with invalid data returns error changeset" do
      artist = artist_fixture()
      assert {:error, %Ecto.Changeset{}} = Playback.update_artist(artist, @invalid_attrs)
      assert artist == Playback.get_artist!(artist.id)
    end

    test "delete_artist/1 deletes the artist" do
      artist = artist_fixture()
      assert {:ok, %Artist{}} = Playback.delete_artist(artist)
      assert_raise Ecto.NoResultsError, fn -> Playback.get_artist!(artist.id) end
    end

    test "change_artist/1 returns a artist changeset" do
      artist = artist_fixture()
      assert %Ecto.Changeset{} = Playback.change_artist(artist)
    end
  end

  describe "albums" do
    alias SpotMe.Playback.Album

    @valid_attrs %{
      artist_id: "some artist_id",
      ext_spotify_id: "some ext_spotify_id",
      images: "some images",
      name: "some name",
      total_tracks: "some total_tracks",
      type: "some type"
    }
    @update_attrs %{
      artist_id: "some updated artist_id",
      ext_spotify_id: "some updated ext_spotify_id",
      images: "some updated images",
      name: "some updated name",
      total_tracks: "some updated total_tracks",
      type: "some updated type"
    }
    @invalid_attrs %{
      artist_id: nil,
      ext_spotify_id: nil,
      images: nil,
      name: nil,
      total_tracks: nil,
      type: nil
    }

    def album_fixture(attrs \\ %{}) do
      {:ok, album} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Playback.create_album()

      album
    end

    test "list_albums/0 returns all albums" do
      album = album_fixture()
      assert Playback.list_albums() == [album]
    end

    test "get_album!/1 returns the album with given id" do
      album = album_fixture()
      assert Playback.get_album!(album.id) == album
    end

    test "create_album/1 with valid data creates a album" do
      assert {:ok, %Album{} = album} = Playback.create_album(@valid_attrs)
      assert album.artist_id == "some artist_id"
      assert album.ext_spotify_id == "some ext_spotify_id"
      assert album.images == "some images"
      assert album.name == "some name"
      assert album.total_tracks == "some total_tracks"
      assert album.type == "some type"
    end

    test "create_album/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Playback.create_album(@invalid_attrs)
    end

    test "update_album/2 with valid data updates the album" do
      album = album_fixture()
      assert {:ok, %Album{} = album} = Playback.update_album(album, @update_attrs)
      assert album.artist_id == "some updated artist_id"
      assert album.ext_spotify_id == "some updated ext_spotify_id"
      assert album.images == "some updated images"
      assert album.name == "some updated name"
      assert album.total_tracks == "some updated total_tracks"
      assert album.type == "some updated type"
    end

    test "update_album/2 with invalid data returns error changeset" do
      album = album_fixture()
      assert {:error, %Ecto.Changeset{}} = Playback.update_album(album, @invalid_attrs)
      assert album == Playback.get_album!(album.id)
    end

    test "delete_album/1 deletes the album" do
      album = album_fixture()
      assert {:ok, %Album{}} = Playback.delete_album(album)
      assert_raise Ecto.NoResultsError, fn -> Playback.get_album!(album.id) end
    end

    test "change_album/1 returns a album changeset" do
      album = album_fixture()
      assert %Ecto.Changeset{} = Playback.change_album(album)
    end
  end

  describe "artists_songs" do
    alias SpotMe.Playback.ArtistsSong

    @valid_attrs %{artist_id: "some artist_id", song_id: "some song_id", type: "some type"}
    @update_attrs %{
      artist_id: "some updated artist_id",
      song_id: "some updated song_id",
      type: "some updated type"
    }
    @invalid_attrs %{artist_id: nil, song_id: nil, type: nil}

    def artists_song_fixture(attrs \\ %{}) do
      {:ok, artists_song} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Playback.create_artists_song()

      artists_song
    end

    test "list_artists_songs/0 returns all artists_songs" do
      artists_song = artists_song_fixture()
      assert Playback.list_artists_songs() == [artists_song]
    end

    test "get_artists_song!/1 returns the artists_song with given id" do
      artists_song = artists_song_fixture()
      assert Playback.get_artists_song!(artists_song.id) == artists_song
    end

    test "create_artists_song/1 with valid data creates a artists_song" do
      assert {:ok, %ArtistsSong{} = artists_song} = Playback.create_artists_song(@valid_attrs)
      assert artists_song.artist_id == "some artist_id"
      assert artists_song.song_id == "some song_id"
      assert artists_song.type == "some type"
    end

    test "create_artists_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Playback.create_artists_song(@invalid_attrs)
    end

    test "update_artists_song/2 with valid data updates the artists_song" do
      artists_song = artists_song_fixture()

      assert {:ok, %ArtistsSong{} = artists_song} =
               Playback.update_artists_song(artists_song, @update_attrs)

      assert artists_song.artist_id == "some updated artist_id"
      assert artists_song.song_id == "some updated song_id"
      assert artists_song.type == "some updated type"
    end

    test "update_artists_song/2 with invalid data returns error changeset" do
      artists_song = artists_song_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Playback.update_artists_song(artists_song, @invalid_attrs)

      assert artists_song == Playback.get_artists_song!(artists_song.id)
    end

    test "delete_artists_song/1 deletes the artists_song" do
      artists_song = artists_song_fixture()
      assert {:ok, %ArtistsSong{}} = Playback.delete_artists_song(artists_song)
      assert_raise Ecto.NoResultsError, fn -> Playback.get_artists_song!(artists_song.id) end
    end

    test "change_artists_song/1 returns a artists_song changeset" do
      artists_song = artists_song_fixture()
      assert %Ecto.Changeset{} = Playback.change_artists_song(artists_song)
    end
  end

  describe "albums_artists" do
    alias SpotMe.Playback.AlbumsArtist

    @valid_attrs %{album_id: "some album_id", artist_id: "some artist_id", type: "some type"}
    @update_attrs %{
      album_id: "some updated album_id",
      artist_id: "some updated artist_id",
      type: "some updated type"
    }
    @invalid_attrs %{album_id: nil, artist_id: nil, type: nil}

    def albums_artist_fixture(attrs \\ %{}) do
      {:ok, albums_artist} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Playback.create_albums_artist()

      albums_artist
    end

    test "list_albums_artists/0 returns all albums_artists" do
      albums_artist = albums_artist_fixture()
      assert Playback.list_albums_artists() == [albums_artist]
    end

    test "get_albums_artist!/1 returns the albums_artist with given id" do
      albums_artist = albums_artist_fixture()
      assert Playback.get_albums_artist!(albums_artist.id) == albums_artist
    end

    test "create_albums_artist/1 with valid data creates a albums_artist" do
      assert {:ok, %AlbumsArtist{} = albums_artist} = Playback.create_albums_artist(@valid_attrs)
      assert albums_artist.album_id == "some album_id"
      assert albums_artist.artist_id == "some artist_id"
      assert albums_artist.type == "some type"
    end

    test "create_albums_artist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Playback.create_albums_artist(@invalid_attrs)
    end

    test "update_albums_artist/2 with valid data updates the albums_artist" do
      albums_artist = albums_artist_fixture()

      assert {:ok, %AlbumsArtist{} = albums_artist} =
               Playback.update_albums_artist(albums_artist, @update_attrs)

      assert albums_artist.album_id == "some updated album_id"
      assert albums_artist.artist_id == "some updated artist_id"
      assert albums_artist.type == "some updated type"
    end

    test "update_albums_artist/2 with invalid data returns error changeset" do
      albums_artist = albums_artist_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Playback.update_albums_artist(albums_artist, @invalid_attrs)

      assert albums_artist == Playback.get_albums_artist!(albums_artist.id)
    end

    test "delete_albums_artist/1 deletes the albums_artist" do
      albums_artist = albums_artist_fixture()
      assert {:ok, %AlbumsArtist{}} = Playback.delete_albums_artist(albums_artist)
      assert_raise Ecto.NoResultsError, fn -> Playback.get_albums_artist!(albums_artist.id) end
    end

    test "change_albums_artist/1 returns a albums_artist changeset" do
      albums_artist = albums_artist_fixture()
      assert %Ecto.Changeset{} = Playback.change_albums_artist(albums_artist)
    end
  end
end
