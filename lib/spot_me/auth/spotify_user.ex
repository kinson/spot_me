defmodule SpotMe.Auth.SpotifyUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "spotify_users" do
    field :display_name, :string
    field :email, :string
    field :images, :map
    field :type, :string
    field :uri, :string
    field :ext_spotify_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(spotify_user, attrs) do
    spotify_user
    |> cast(attrs, [:ext_spotify_id, :display_name, :images, :type, :uri, :email])
    |> validate_required([:ext_spotify_id, :display_name, :images, :type, :uri, :email])
    |> unique_constraint(:ext_spotify_id)
  end
end
