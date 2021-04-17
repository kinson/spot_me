defmodule SpotMe.Playback.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "artists" do
    field :ext_spotify_id, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:ext_spotify_id, :name])
    |> validate_required([:ext_spotify_id, :name])
  end
end
