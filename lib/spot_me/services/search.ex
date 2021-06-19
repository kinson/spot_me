defmodule SpotMe.Services.Search do
  alias SpotMe.Configs.Spotify
  alias SpotMe.Services.Models.AlbumResult

  def search_albums(search_term, access_token) do
    base_url = Spotify.api_base_url()

    endpoint = Spotify.search_endpoint()

    headers = [Authorization: "Bearer #{access_token}"]
    term = String.replace(search_term, ~r/\s/, "%20")
    query = "?q=#{term}&type=album&market=US&limit=20"

    url = base_url <> endpoint <> query

    HTTPoison.get(url, headers)
    |> parse_response()
  end

  defp parse_response({:error, err}), do: {:error, err}

  defp parse_response({:ok, response}) do
    albums =
      Map.get(response, :body)
      |> Jason.decode!()
      |> Map.get("albums")
      |> Map.get("items")
      |> Enum.filter(&is_album_type/1)
      |> Enum.map(&extract_album_info/1)

    {:ok, albums}
  end

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
