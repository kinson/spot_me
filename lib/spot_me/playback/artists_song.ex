defmodule SpotMe.Playback.ArtistsSong do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "artists_songs" do
    field :type, :string

    belongs_to :song, SpotMe.Playback.Song, type: :binary_id
    belongs_to :artist, SpotMe.Playback.Artist, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(artists_song, attrs) do
    artists_song
    |> cast(attrs, [:artist_id, :song_id, :type])
    |> validate_required([:artist_id, :song_id, :type])
  end
end
