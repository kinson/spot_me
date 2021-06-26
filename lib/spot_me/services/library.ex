defmodule SpotMe.Services.Library do
  alias SpotMe.Configs.Spotify
  alias SpotMe.Services.Models.AlbumResult

  def get_albums(access_token) do
    IO.puts "fetching users albums"
    base_url = Spotify.api_base_url()

    endpoint = Spotify.saved_albums_endpoint()

    headers = [Authorization: "Bearer #{access_token}"]
    query = "?market=US&limit=50"

    url = base_url <> endpoint <> query

    HTTPoison.get(url, headers)
    |> parse_response()
  end

  defp parse_response({:error, err}), do: {:error, err}

  defp parse_response({:ok, response}) do
    albums =
      Map.get(response, :body)
      |> Jason.decode!()
      |> Map.get("items")
      |> Enum.map(&get_album_data/1)
      |> Enum.filter(&is_album_type/1)
      |> Enum.map(&extract_album_info/1)

    {:ok, albums}
  end

  defp get_album_data(%{"album" => album}), do: album

  defp is_album_type(%{"album_type" => "album"}), do: true
  defp is_album_type(%{"album_type" => _}), do: false

  defp extract_album_info(album) do
    name = Map.get(album, "name")

    uri = Map.get(album, "uri")

    artists_names =
      Map.get(album, "artists")
      |> Enum.map(fn %{"name" => name} ->
        name
      end)
      |> Enum.join(", ")

    album_cover_url =
      Map.get(album, "images")
      |> Enum.at(1)
      |> Map.get("url")

    %AlbumResult{
      name: name,
      album_cover_url: album_cover_url,
      artists_names: artists_names,
      uri: uri
    }
  end
end
