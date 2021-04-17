defmodule SpotMe.Services.Profile do
  def get_profile_data(%{access_token: access_token}) do
    # get the profile info from Spotify

    base_url = SpotMe.Configs.Spotify.api_base_url()
    profile_endpoint = SpotMe.Configs.Spotify.profile_endpoint()

    url = base_url <> profile_endpoint
    headers = [Authorization: "Bearer #{access_token}"]

    HTTPoison.get(url, headers)
    |> parse_profile_response()
  end

  defp parse_profile_response({:error, err}), do: {:error, err}

  defp parse_profile_response({:ok, response}) do
    %{
      "id" => id,
      "uri" => uri,
      "email" => email,
      "display_name" => display_name,
      "images" => images,
      "type" => type
    } =
      Map.get(response, :body)
      |> Jason.decode!()

    %{
      ext_spotify_id: id,
      display_name: display_name,
      uri: uri,
      email: email,
      type: type,
      images: %{data: images}
    }
  end
end
