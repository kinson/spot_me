defmodule SpotMe.Playback.Song do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "songs" do
    field :duration_ms, :integer
    field :ext_spotify_id, :string
    field :name, :string

    belongs_to :album, SpotMe.Playback.Album, type: :binary_id

    many_to_many :artists, SpotMe.Playback.Artist, join_through: "artists_songs"
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:ext_spotify_id, :name, :duration_ms, :album_id])
    |> validate_required([:ext_spotify_id, :name, :duration_ms, :album_id])
  end
end
