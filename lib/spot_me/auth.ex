defmodule SpotMe.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias SpotMe.Repo

  alias SpotMe.Auth.{SpotifyUser, TokenSet}

  def upsert_token_set(%{spotify_user_id: spotify_user_id} = attrs) do
    case Repo.get_by(TokenSet, spotify_user_id: spotify_user_id) do
      nil -> %TokenSet{}
      existing_token_set -> existing_token_set
    end
    |> TokenSet.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def upsert_spotify_user(%{ext_spotify_id: ext_spotify_id} = attrs) do
    case Repo.get_by(SpotifyUser, ext_spotify_id: ext_spotify_id) do
      nil -> %SpotifyUser{}
      existing_spotify_user -> existing_spotify_user
    end
    |> SpotifyUser.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def get_users_and_live_tokens() do
    now = DateTime.utc_now()

    from(t in TokenSet,
      join: su in assoc(t, :spotify_user),
      select: {su.id, t.access_token},
      where: t.expires_at > ^now
    )
    |> Repo.all()
  end

  def get_the_token() do
    {_, token} =
      get_users_and_live_tokens()
      |> hd()

    token
  end

  def get_tokens_near_expiration(date) do
    from(ts in TokenSet, where: ts.expires_at < ^date, select: ts)
    |> Repo.all()
  end
end
