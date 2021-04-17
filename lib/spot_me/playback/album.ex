defmodule SpotMe.Playback.Album do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "albums" do
    field :ext_spotify_id, :string
    field :images, :string
    field :name, :string
    field :total_tracks, :string
    field :type, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, [:ext_spotify_id, :artist_id, :name, :total_tracks, :images, :type])
    |> validate_required([:ext_spotify_id, :artist_id, :name, :total_tracks, :images, :type])
  end
end
