defmodule SpotMe.Playback.Play do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "plays" do
    field :played_at, :utc_datetime

    belongs_to :song, SpotMe.Playback.Song, type: :binary_id
    belongs_to :spotify_user, SpotMe.Auth.SpotifyUser, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(play, attrs) do
    play
    |> cast(attrs, [:played_at, :song_id, :spotify_user_id])
    |> validate_required([:played_at, :song_id, :spotify_user_id])
    |> unique_constraint([:played_at, :song_id, :spotify_user_id], name: :plays_spotify_user_id_played_at_song_id_index)
  end
end
