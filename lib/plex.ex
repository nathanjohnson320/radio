defmodule Plex do
  alias Radio.Media

  @token Application.get_env(:radio, :plex_token)
  @endpoint Application.get_env(:radio, :plex_endpoint)

  defp base_url(), do: @endpoint

  defp token(), do: @token

  def list_artists(section_key \\ "3") do
    %{
      "MediaContainer" => %{
        "Metadata" => artists
      }
    } = grab_key("/library/sections/#{section_key}/all")

    Enum.map(artists, fn %{"key" => key} = params ->
      case Media.get_artist_by(key: key) do
        {:ok, artist} ->
          artist

        {:error, :not_found} ->
          country = Map.get(params, "Country") || []
          genre = Map.get(params, "Genre") || []

          genre =
            Enum.map(genre, fn %{"tag" => genre} ->
              {:ok, genre} = Media.get_or_create_genre(%{"name" => genre})
              genre.id
            end)

          {:ok, artist} =
            Media.create_artist(%{
              "rating_key" => Map.get(params, "ratingKey"),
              "key" => key,
              "guid" => Map.get(params, "guid"),
              "art" => Map.get(params, "art"),
              "country" => tags(country),
              "genre" => genre,
              "index" => Map.get(params, "index"),
              "name" => Map.get(params, "title"),
              "summary" => Map.get(params, "summary"),
              "thumb" => Map.get(params, "thumb")
            })

          artist
      end
    end)
  end

  def get_albums(artist) do
    %{
      "MediaContainer" => %{
        "Metadata" => albums
      }
    } = grab_key(artist.key)

    Enum.map(albums, fn %{"key" => key} = params ->
      case Media.get_album_by(key: key) do
        {:ok, album} ->
          album

        {:error, :not_found} ->
          director = Map.get(params, "Director") || []
          genre = Map.get(params, "Genre") || []

          genre =
            Enum.map(genre, fn %{"tag" => genre} ->
              {:ok, genre} = Media.get_or_create_genre(%{"name" => genre})
              genre.id
            end)

          {:ok, album} =
            Media.create_album(%{
              "artist_id" => artist.id,
              "art" => Map.get(params, "art"),
              "genre" => genre,
              "director" => tags(director),
              "guid" => Map.get(params, "guid"),
              "index" => Map.get(params, "index"),
              "key" => Map.get(params, "key"),
              "studio" => Map.get(params, "studio"),
              "summary" => Map.get(params, "summary"),
              "thumb" => Map.get(params, "thumb"),
              "title" => Map.get(params, "title"),
              "year" => Map.get(params, "year")
            })

          album
      end
    end)
  end

  def get_songs(album) do
    %{
      "MediaContainer" => %{
        "Metadata" => songs
      }
    } = grab_key(album.key)

    Enum.map(songs, fn %{"key" => key} = params ->
      case Media.get_song_by(key: key) do
        {:ok, song} ->
          song

        {:error, :not_found} ->
          media = List.first(Map.get(params, "Media") || [])
          part = List.first(Map.get(media, "Part") || [])

          {:ok, song} =
            Media.create_song(%{
              "album_id" => album.id,
              "key" => Map.get(params, "key"),
              "guid" => Map.get(params, "guid"),
              "title" => Map.get(params, "title"),
              "summary" => Map.get(params, "summary"),
              "index" => Map.get(params, "index"),
              "thumb" => Map.get(params, "thumb"),
              "art" => Map.get(params, "art"),
              "duration" => Map.get(params, "duration"),
              "bitrate" => Map.get(media, "bitrate"),
              "audio_channels" => Map.get(media, "audioChannels"),
              "audio_codec" => Map.get(media, "audioCodec"),
              "container" => Map.get(media, "container"),
              "file" => Map.get(part, "file"),
              "size" => Map.get(part, "size")
            })

          song
      end
    end)
  end

  def sync() do
    # Grab all the artists
    artists = list_artists()

    artists
    |> Enum.each(fn artist ->
      albums = get_albums(artist)

      Enum.each(albums, fn album ->
        get_songs(album)
      end)
    end)
  end

  def image(key) do
    with {:ok, %Mojito.Response{body: body, headers: headers}} <-
           Mojito.get("#{base_url()}#{key}?X-Plex-Token=#{token()}") do
      {:ok, {body, headers}}
    end
  end

  defp grab_key(key) do
    with {:ok, %Mojito.Response{body: body}} <-
           Mojito.get("#{base_url()}#{key}?X-Plex-Token=#{token()}", [
             {"Accept", "application/json"}
           ]),
         {:ok, parsed} <- Jason.decode(body) do
      parsed
    end
  end

  defp tags(tags), do: tags |> Enum.map(&Map.get(&1, "tag"))

  def audio_url(key) do
    "#{base_url()}#{key}?X-Plex-Token=#{token()}"
  end
end
