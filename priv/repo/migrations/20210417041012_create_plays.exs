defmodule SpotMe.Repo.Migrations.CreatePlays do
  use Ecto.Migration

  def change do
    create table(:artists, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ext_spotify_id, :string
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create table(:albums, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ext_spotify_id, :string
      add :name, :string
      add :total_tracks, :integer
      add :images, :map
      add :type, :string

      timestamps(type: :utc_datetime)
    end

    create table(:songs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ext_spotify_id, :string
      add :name, :string
      add :duration_ms, :integer
      add :album_id, references(:albums, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:albums, :ext_spotify_id)
    create unique_index(:songs, :ext_spotify_id)

    create table(:plays, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :played_at, :utc_datetime
      add :song_id, references(:songs, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create table(:artists_songs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :artist_id, references(:artists, type: :binary_id)
      add :song_id, references(:songs, type: :binary_id)
      add :type, :string

      timestamps(type: :utc_datetime)
    end

    create table(:albums_artists, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :artist_id, references(:artists, type: :binary_id)
      add :album_id, references(:albums, type: :binary_id)
      add :type, :string

      timestamps(type: :utc_datetime)
    end
  end
end
