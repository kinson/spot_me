defmodule SpotMe.Repo.Migrations.WidenTokenColumns do
  use Ecto.Migration

  def change do
    alter table(:token_sets) do
      modify :access_token, :text
      modify :refresh_token, :text
    end
  end
end
