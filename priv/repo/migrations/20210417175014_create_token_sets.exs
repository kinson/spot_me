defmodule SpotMe.Repo.Migrations.CreateTokenSets do
  use Ecto.Migration

  def change do
    create table(:spotify_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ext_spotify_id, :string
      add :display_name, :string
      add :images, :map
      add :type, :string
      add :uri, :string
      add :email, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:spotify_users, :ext_spotify_id)

    create table(:token_sets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :access_token, :string
      add :refresh_token, :string
      add :expires_at, :utc_datetime
      add :expires_in, :integer
      add :token_type, :string
      add :scope, :string
      add :spotify_user_id, references(:spotify_users, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:token_sets, :spotify_user_id)
  end
end
