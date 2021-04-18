defmodule SpotMe.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias SpotMe.Repo

  alias SpotMe.Auth.TokenSet

  @doc """
  Returns the list of token_sets.

  ## Examples

      iex> list_token_sets()
      [%TokenSet{}, ...]

  """
  def list_token_sets do
    Repo.all(TokenSet)
  end

  @doc """
  Gets a single token_set.

  Raises `Ecto.NoResultsError` if the Token set does not exist.

  ## Examples

      iex> get_token_set!(123)
      %TokenSet{}

      iex> get_token_set!(456)
      ** (Ecto.NoResultsError)

  """
  def get_token_set!(id), do: Repo.get!(TokenSet, id)

  @doc """
  Creates a token_set.

  ## Examples

      iex> create_token_set(%{field: value})
      {:ok, %TokenSet{}}

      iex> create_token_set(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_token_set(attrs \\ %{}) do
    %TokenSet{}
    |> TokenSet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a token_set.

  ## Examples

      iex> update_token_set(token_set, %{field: new_value})
      {:ok, %TokenSet{}}

      iex> update_token_set(token_set, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_token_set(%TokenSet{} = token_set, attrs) do
    token_set
    |> TokenSet.changeset(attrs)
    |> Repo.update()
  end

  def upsert_token_set(%{spotify_user_id: spotify_user_id} = attrs) do
    case Repo.get_by(TokenSet, spotify_user_id: spotify_user_id) do
      nil -> %TokenSet{}
      existing_token_set -> existing_token_set
    end
    |> TokenSet.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Deletes a token_set.

  ## Examples

      iex> delete_token_set(token_set)
      {:ok, %TokenSet{}}

      iex> delete_token_set(token_set)
      {:error, %Ecto.Changeset{}}

  """
  def delete_token_set(%TokenSet{} = token_set) do
    Repo.delete(token_set)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking token_set changes.

  ## Examples

      iex> change_token_set(token_set)
      %Ecto.Changeset{data: %TokenSet{}}

  """
  def change_token_set(%TokenSet{} = token_set, attrs \\ %{}) do
    TokenSet.changeset(token_set, attrs)
  end

  alias SpotMe.Auth.SpotifyUser

  @doc """
  Returns the list of spotify_users.

  ## Examples

      iex> list_spotify_users()
      [%SpotifyUser{}, ...]

  """
  def list_spotify_users do
    Repo.all(SpotifyUser)
  end

  @doc """
  Gets a single spotify_user.

  Raises `Ecto.NoResultsError` if the Spotify user does not exist.

  ## Examples

      iex> get_spotify_user!(123)
      %SpotifyUser{}

      iex> get_spotify_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_spotify_user!(id), do: Repo.get!(SpotifyUser, id)

  @doc """
  Creates a spotify_user.

  ## Examples

      iex> create_spotify_user(%{field: value})
      {:ok, %SpotifyUser{}}

      iex> create_spotify_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_spotify_user(attrs \\ %{}) do
    %SpotifyUser{}
    |> SpotifyUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a spotify_user.

  ## Examples

      iex> update_spotify_user(spotify_user, %{field: new_value})
      {:ok, %SpotifyUser{}}

      iex> update_spotify_user(spotify_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_spotify_user(%SpotifyUser{} = spotify_user, attrs) do
    spotify_user
    |> SpotifyUser.changeset(attrs)
    |> Repo.update()
  end

  def upsert_spotify_user(%{ext_spotify_id: ext_spotify_id} = attrs) do
    case Repo.get_by(SpotifyUser, ext_spotify_id: ext_spotify_id) do
      nil -> %SpotifyUser{}
      existing_spotify_user -> existing_spotify_user
    end
    |> SpotifyUser.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Deletes a spotify_user.

  ## Examples

      iex> delete_spotify_user(spotify_user)
      {:ok, %SpotifyUser{}}

      iex> delete_spotify_user(spotify_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_spotify_user(%SpotifyUser{} = spotify_user) do
    Repo.delete(spotify_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking spotify_user changes.

  ## Examples

      iex> change_spotify_user(spotify_user)
      %Ecto.Changeset{data: %SpotifyUser{}}

  """
  def change_spotify_user(%SpotifyUser{} = spotify_user, attrs \\ %{}) do
    SpotifyUser.changeset(spotify_user, attrs)
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

  def get_tokens_near_expiration(date) do
    from(ts in TokenSet, where: ts.expires_at < ^date, select: ts)
    |> Repo.all()
  end
end
