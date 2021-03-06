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
    |> unique_constraint([:played_at, :song_id, :spotify_user_id],
      name: :plays_spotify_user_id_played_at_song_id_index
    )
  end

  def is_duplicate_play?(%DateTime{} = played_at_one, %DateTime{} = played_at_two) do
    diff = DateTime.diff(played_at_one, played_at_two, :millisecond) |> abs()
    two_hours = :timer.hours(2)

    case diff < two_hours do
      true ->
        IO.puts("Deduping play")
        true

      false ->
        false
    end
  end

  def is_duplicate_play?(%DateTime{} = played_at_one, played_at_two) do
    {:ok, two, _} = DateTime.from_iso8601(played_at_two)

    is_duplicate_play?(played_at_one, two)
  end

  def is_duplicate_play?(played_at_one, %DateTime{} = played_at_two) do
    {:ok, one, _} = DateTime.from_iso8601(played_at_one)

    is_duplicate_play?(one, played_at_two)
  end

  def is_duplicate_play?(played_at_one, played_at_two) do
    {:ok, one, _} = DateTime.from_iso8601(played_at_one)
    {:ok, two, _} = DateTime.from_iso8601(played_at_two)

    is_duplicate_play?(one, two)
  end

  def get_display_list(plays) do
    Enum.reduce(plays, [nil], fn play, acc ->
      [top | rest] = acc

      case top do
        nil ->
          [{1, play.song}]

        {count, song} ->
          case song.album.id == play.song.album.id do
            true -> [{count + 1, song} | rest]
            false -> [{1, play.song} | acc]
          end
      end
    end)
    |> Enum.reverse()
  end
end
