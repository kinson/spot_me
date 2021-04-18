defmodule SpotMe.Repo.Migrations.CreateSpotifyUsers do
  use Ecto.Migration

  def change do
    alter table(:plays) do
      add :spotify_user_id, references(:spotify_users, type: :binary_id)
    end

    create unique_index(:plays, [:spotify_user_id, :played_at, :song_id])
  end
end
