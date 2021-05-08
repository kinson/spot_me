defmodule SpotMeWeb.PageView do
  use SpotMeWeb, :view

  alias SpotMe.Playback.Song

  def disc_icon() do
    ~E"""
    <svg width="12px" height="12px" viewBox="0 0 12 12" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
      <g id="Artboard" transform="translate(-267.000000, -200.000000)" stroke="#979797">
          <g id="Group-2" transform="translate(267.000000, 200.000000)">
              <circle id="Oval" cx="6" cy="6" r="5.5"></circle>
              <circle id="Oval" cx="6" cy="6" r="1"></circle>
          </g>
      </g>
      </g>
    </svg>
    """
  end

  def artist_icon() do
    ~E"""
      <svg width="12px" height="15px" viewBox="0 0 12 15" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
          <g id="Artboard" transform="translate(-267.000000, -216.000000)" fill-rule="nonzero" stroke="#979797">
              <g id="user-solid" transform="translate(268.000000, 217.000000)">
                  <path d="M5.25,6 C6.90703125,6 8.25,4.65703125 8.25,3 C8.25,1.34296875 6.90703125,0 5.25,0 C3.59296875,0 2.25,1.34296875 2.25,3 C2.25,4.65703125 3.59296875,6 5.25,6 Z M7.35,7.75 L6.95859375,7.75 C6.43828125,7.9890625 5.859375,8.125 5.25,8.125 C4.640625,8.125 4.0640625,7.9890625 3.54140625,7.75 L3.15,7.75 C1.4109375,7.75 0,9.1609375 0,10.9 L0,11.875 C0,12.4960938 0.50390625,13 1.125,13 L9.375,13 C9.99609375,13 10.5,12.4960938 10.5,11.875 L10.5,10.9 C10.5,9.1609375 9.0890625,7.75 7.35,7.75 Z" id="Shape"></path>
              </g>
          </g>
      </g>
      </svg>
    """
  end

  def album_icon() do
    ~E"""
      <svg width="9px" height="12px" viewBox="0 0 9 12" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
          <g id="Artboard" transform="translate(-268.000000, -239.000000)" stroke="#979797">
              <g id="Group-3" transform="translate(268.000000, 239.000000)">
                  <rect id="Rectangle" fill="#D8D8D8" x="0.5" y="0.5" width="8" height="8"></rect>
                  <path d="M0.5,0.693712943 L8.5,3.36037961 L8.5,11.3062871 L0.5,8.63962039 L0.5,0.693712943 Z" id="Rectangle" fill="#FFFFFF"></path>
              </g>
          </g>
      </g>
      </svg>
    """
  end

  def album_image(song) do
    song.album.images
    |> Map.get("data")
    |> Enum.at(1)
    |> Map.get("url")
  end

  def truncate_text(text, limit) do
    total = limit - 2

    case String.length(text) > limit do
      false -> text
      true -> String.slice(text, 0..total) <> ".."
    end
  end

  def first_row(count, song) do
    case count > 1 do
      true -> truncate_text(song.album.name, 32)
      false -> truncate_text(song.name, 32)
    end
  end

  def second_row(song) do
    song.artists
    |> Enum.sort()
    |> Enum.map(&Map.get(&1, :name))
    |> Enum.join(", ")
    |> truncate_text(36)
  end

  def third_row(count, song) do
    case count > 1 do
      true -> "#{count} songs"
      false -> truncate_text(song.album.name, 36)
    end
  end

  def first_row_icon(count) do
    case count > 1 do
      true -> album_icon()
      false -> disc_icon()
    end
  end

  def third_row_icon(count) do
    case count > 1 do
      true -> disc_icon()
      false -> album_icon()
    end
  end

  def first_row_link(count, song) do
    case count > 1 do
      true -> album_link(song)
      false -> song_link(song)
    end
  end

  def artist_link(%Song{} = song) do
    id =
      song.artists
      |> Enum.sort()
      |> Enum.map(&Map.get(&1, :ext_spotify_id))
      |> hd()

    "https://open.spotify.com/artist/" <> id
  end

  def artist_link(%{artist_id: id}) do
    "https://open.spotify.com/artist/" <> id
  end

  def song_link(%Song{} = song) do
    id = song.ext_spotify_id

    "https://open.spotify.com/track/" <> id
  end

  def song_link(%{song_id: id}) do
    "https://open.spotify.com/track/" <> id
  end

  def album_link(%Song{} = song) do
    id = song.album.ext_spotify_id

    "https://open.spotify.com/album/" <> id
  end

  def album_link(%{album_id: id}) do
    "https://open.spotify.com/album/" <> id
  end
end
