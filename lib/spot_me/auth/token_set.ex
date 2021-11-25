defmodule SpotMe.Auth.TokenSet do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "token_sets" do
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime
    field :expires_in, :integer
    field :token_type, :string
    field :scope, :string

    belongs_to :spotify_user, SpotMe.Auth.SpotifyUser, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(token_set, attrs) do
    token_set
    |> cast(attrs, [
      :access_token,
      :refresh_token,
      :expires_at,
      :expires_in,
      :scope,
      :token_type,
      :spotify_user_id
    ])
    |> validate_required([
      :access_token,
      :refresh_token,
      :expires_at,
      :expires_in,
      :scope,
      :spotify_user_id
    ])
    |> unique_constraint(:spotify_user_id)
  end
end
