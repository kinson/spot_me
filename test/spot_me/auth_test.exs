defmodule SpotMe.AuthTest do
  use SpotMe.DataCase

  alias SpotMe.Auth

  describe "token_sets" do
    alias SpotMe.Auth.TokenSet

    @valid_attrs %{access_token: "some access_token", expires_at: "some expires_at", refresh_token: "some refresh_token"}
    @update_attrs %{access_token: "some updated access_token", expires_at: "some updated expires_at", refresh_token: "some updated refresh_token"}
    @invalid_attrs %{access_token: nil, expires_at: nil, refresh_token: nil}

    def token_set_fixture(attrs \\ %{}) do
      {:ok, token_set} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_token_set()

      token_set
    end

    test "list_token_sets/0 returns all token_sets" do
      token_set = token_set_fixture()
      assert Auth.list_token_sets() == [token_set]
    end

    test "get_token_set!/1 returns the token_set with given id" do
      token_set = token_set_fixture()
      assert Auth.get_token_set!(token_set.id) == token_set
    end

    test "create_token_set/1 with valid data creates a token_set" do
      assert {:ok, %TokenSet{} = token_set} = Auth.create_token_set(@valid_attrs)
      assert token_set.access_token == "some access_token"
      assert token_set.expires_at == "some expires_at"
      assert token_set.refresh_token == "some refresh_token"
    end

    test "create_token_set/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_token_set(@invalid_attrs)
    end

    test "update_token_set/2 with valid data updates the token_set" do
      token_set = token_set_fixture()
      assert {:ok, %TokenSet{} = token_set} = Auth.update_token_set(token_set, @update_attrs)
      assert token_set.access_token == "some updated access_token"
      assert token_set.expires_at == "some updated expires_at"
      assert token_set.refresh_token == "some updated refresh_token"
    end

    test "update_token_set/2 with invalid data returns error changeset" do
      token_set = token_set_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_token_set(token_set, @invalid_attrs)
      assert token_set == Auth.get_token_set!(token_set.id)
    end

    test "delete_token_set/1 deletes the token_set" do
      token_set = token_set_fixture()
      assert {:ok, %TokenSet{}} = Auth.delete_token_set(token_set)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_token_set!(token_set.id) end
    end

    test "change_token_set/1 returns a token_set changeset" do
      token_set = token_set_fixture()
      assert %Ecto.Changeset{} = Auth.change_token_set(token_set)
    end
  end

  describe "spotify_users" do
    alias SpotMe.Auth.SpotifyUser

    @valid_attrs %{display_name: "some display_name", email: "some email", ext_spotify_id: "some ext_spotify_id", images: "some images", product: "some product", type: "some type", uri: "some uri"}
    @update_attrs %{display_name: "some updated display_name", email: "some updated email", ext_spotify_id: "some updated ext_spotify_id", images: "some updated images", product: "some updated product", type: "some updated type", uri: "some updated uri"}
    @invalid_attrs %{display_name: nil, email: nil, ext_spotify_id: nil, images: nil, product: nil, type: nil, uri: nil}

    def spotify_user_fixture(attrs \\ %{}) do
      {:ok, spotify_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_spotify_user()

      spotify_user
    end

    test "list_spotify_users/0 returns all spotify_users" do
      spotify_user = spotify_user_fixture()
      assert Auth.list_spotify_users() == [spotify_user]
    end

    test "get_spotify_user!/1 returns the spotify_user with given id" do
      spotify_user = spotify_user_fixture()
      assert Auth.get_spotify_user!(spotify_user.id) == spotify_user
    end

    test "create_spotify_user/1 with valid data creates a spotify_user" do
      assert {:ok, %SpotifyUser{} = spotify_user} = Auth.create_spotify_user(@valid_attrs)
      assert spotify_user.display_name == "some display_name"
      assert spotify_user.email == "some email"
      assert spotify_user.ext_spotify_id == "some ext_spotify_id"
      assert spotify_user.images == "some images"
      assert spotify_user.product == "some product"
      assert spotify_user.type == "some type"
      assert spotify_user.uri == "some uri"
    end

    test "create_spotify_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_spotify_user(@invalid_attrs)
    end

    test "update_spotify_user/2 with valid data updates the spotify_user" do
      spotify_user = spotify_user_fixture()
      assert {:ok, %SpotifyUser{} = spotify_user} = Auth.update_spotify_user(spotify_user, @update_attrs)
      assert spotify_user.display_name == "some updated display_name"
      assert spotify_user.email == "some updated email"
      assert spotify_user.ext_spotify_id == "some updated ext_spotify_id"
      assert spotify_user.images == "some updated images"
      assert spotify_user.product == "some updated product"
      assert spotify_user.type == "some updated type"
      assert spotify_user.uri == "some updated uri"
    end

    test "update_spotify_user/2 with invalid data returns error changeset" do
      spotify_user = spotify_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_spotify_user(spotify_user, @invalid_attrs)
      assert spotify_user == Auth.get_spotify_user!(spotify_user.id)
    end

    test "delete_spotify_user/1 deletes the spotify_user" do
      spotify_user = spotify_user_fixture()
      assert {:ok, %SpotifyUser{}} = Auth.delete_spotify_user(spotify_user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_spotify_user!(spotify_user.id) end
    end

    test "change_spotify_user/1 returns a spotify_user changeset" do
      spotify_user = spotify_user_fixture()
      assert %Ecto.Changeset{} = Auth.change_spotify_user(spotify_user)
    end
  end
end
