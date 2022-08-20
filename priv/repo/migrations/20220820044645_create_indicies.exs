defmodule SpotMe.Repo.Migrations.CreateIndicies do
  use Ecto.Migration

  def change do
    create_if_not_exists unique_index("albums", [:ext_spotify_id])
    create_if_not_exists unique_index("songs", [:ext_spotify_id])
    create_if_not_exists unique_index("spotify_users", [:ext_spotify_id])
    create_if_not_exists unique_index("token_sets", [:spotify_user_id])
    create_if_not_exists unique_index("plays", [:spotify_user_id, :played_at, :song_id])
  end
end
