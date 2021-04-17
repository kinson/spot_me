defmodule SpotMe.Playback.AlbumsArtist do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "albums_artists" do
    field :type, :string

    belongs_to :album, SpotMe.Playback.Album, type: :binary_id
    belongs_to :artist, SpotMe.Playback.Artist, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(albums_artist, attrs) do
    albums_artist
    |> cast(attrs, [:artist_id, :album_id, :type])
    |> validate_required([:artist_id, :album_id, :type])
  end
end
