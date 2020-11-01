defmodule Radio.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false
  alias Radio.Repo

  alias Radio.Media.Album
  alias Radio.Media.Artist
  alias Radio.Media.Genre

  @doc """
  Returns the list of artists.

  ## Examples

      iex> list_artists()
      [%Artist{}, ...]

  """
  def list_artists do
    from(artist in Artist,
      order_by: artist.name
    )
    |> Repo.all()
  end

  def list_artists_in_genres(genres) do
    genres = Enum.map(genres, & &1.name)

    artists =
      from(artist in Artist,
        join: genre in assoc(artist, :genres),
        where: genre.name in ^genres,
        order_by: artist.name,
        distinct: true
      )
      |> Repo.all()

    album_artists =
      from(album in Album,
        join: genre in assoc(album, :genres),
        join: artist in assoc(album, :artist),
        where: genre.name in ^genres,
        order_by: artist.name,
        distinct: true,
        select: artist
      )
      |> Repo.all()

    (artists ++ album_artists) |> Enum.uniq_by(& &1.id)
  end

  def list_albums_for_artist_in_genres(artist, genres) do
    genres = Enum.map(genres, & &1.id)

    from(album in Album,
      join: genre in assoc(album, :genres),
      where: genre.id in ^genres and album.artist_id == ^artist.id,
      order_by: album.title,
      distinct: true
    )
    |> Repo.all()
  end

  @doc """
  Gets a single artist.

  Raises `Ecto.NoResultsError` if the Artist does not exist.

  ## Examples

      iex> get_artist!(123)
      %Artist{}

      iex> get_artist!(456)
      ** (Ecto.NoResultsError)

  """
  def get_artist!(nil), do: nil
  def get_artist!(id), do: Repo.get!(Artist, id)

  def get_artist_by(params) do
    case Repo.get_by(Artist, params) do
      nil -> {:error, :not_found}
      artist -> {:ok, artist}
    end
  end

  @doc """
  Creates a artist.

  ## Examples

      iex> create_artist(%{field: value})
      {:ok, %Artist{}}

      iex> create_artist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_artist(attrs \\ %{}) do
    genres =
      if not is_nil(attrs["genre"]) do
        from(g in Genre, where: g.id in ^attrs["genre"]) |> Repo.all()
      else
        []
      end

    %Artist{}
    |> Artist.changeset(attrs, genres)
    |> Repo.insert()
  end

  @doc """
  Updates a artist.

  ## Examples

      iex> update_artist(artist, %{field: new_value})
      {:ok, %Artist{}}

      iex> update_artist(artist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_artist(%Artist{} = artist, attrs) do
    genres =
      if not is_nil(attrs["genre"]) do
        from(g in Genre, where: g.id in ^attrs["genre"]) |> Repo.all()
      else
        []
      end

    artist
    |> Artist.changeset(attrs, genres)
    |> Repo.update()
  end

  @doc """
  Deletes a artist.

  ## Examples

      iex> delete_artist(artist)
      {:ok, %Artist{}}

      iex> delete_artist(artist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_artist(%Artist{} = artist) do
    Repo.delete(artist)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking artist changes.

  ## Examples

      iex> change_artist(artist)
      %Ecto.Changeset{data: %Artist{}}

  """
  def change_artist(%Artist{} = artist, attrs \\ %{}, genres \\ []) do
    Artist.changeset(artist, attrs, genres)
  end

  @doc """
  Returns the list of albums.

  ## Examples

      iex> list_albums()
      [%Album{}, ...]

  """
  def list_albums do
    Repo.all(Album)
  end

  def list_albums_for_artist(artist) do
    from(album in Album,
      where: album.artist_id == ^artist.id,
      distinct: true
    )
    |> Repo.all()
  end

  @doc """
  Gets a single album.

  Raises `Ecto.NoResultsError` if the Album does not exist.

  ## Examples

      iex> get_album!(123)
      %Album{}

      iex> get_album!(456)
      ** (Ecto.NoResultsError)

  """
  def get_album!(nil), do: nil
  def get_album!(id), do: Repo.get!(Album, id)

  def get_album_by(params) do
    case Repo.get_by(Album, params) do
      nil -> {:error, :not_found}
      song -> {:ok, song}
    end
  end

  @doc """
  Creates a album.

  ## Examples

      iex> create_album(%{field: value})
      {:ok, %Album{}}

      iex> create_album(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_album(attrs \\ %{}) do
    genres =
      if not is_nil(attrs["genre"]) do
        from(g in Genre, where: g.id in ^attrs["genre"]) |> Repo.all()
      else
        []
      end

    %Album{}
    |> Album.changeset(attrs, genres)
    |> Repo.insert()
  end

  @doc """
  Updates a album.

  ## Examples

      iex> update_album(album, %{field: new_value})
      {:ok, %Album{}}

      iex> update_album(album, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_album(%Album{} = album, attrs) do
    genres =
      if not is_nil(attrs["genre"]) do
        from(g in Genre, where: g.id in ^attrs["genre"]) |> Repo.all()
      else
        []
      end

    album
    |> Album.changeset(attrs, genres)
    |> Repo.update()
  end

  @doc """
  Deletes a album.

  ## Examples

      iex> delete_album(album)
      {:ok, %Album{}}

      iex> delete_album(album)
      {:error, %Ecto.Changeset{}}

  """
  def delete_album(%Album{} = album) do
    Repo.delete(album)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking album changes.

  ## Examples

      iex> change_album(album)
      %Ecto.Changeset{data: %Album{}}

  """
  def change_album(%Album{} = album, attrs \\ %{}, genres \\ []) do
    Album.changeset(album, attrs, genres)
  end

  alias Radio.Media.Song

  @doc """
  Returns the list of songs.

  ## Examples

      iex> list_songs()
      [%Song{}, ...]

  """
  def list_songs(offset \\ 0, limit \\ 20) do
    from(Song, limit: ^limit, offset: ^offset)
    |> Repo.all()
  end

  def list_songs_for_album(album) do
    from(song in Song,
      where: song.album_id == ^album.id and song.audio_codec == "mp3",
      order_by: song.index
    )
    |> Repo.all()
  end

  @doc """
  Gets a single song.

  Raises `Ecto.NoResultsError` if the Song does not exist.

  ## Examples

      iex> get_song!(123)
      %Song{}

      iex> get_song!(456)
      ** (Ecto.NoResultsError)

  """
  def get_song!(nil), do: nil
  def get_song!(id), do: Repo.get!(Song, id)

  def get_song_by(params) do
    case Repo.get_by(Song, params) do
      nil -> {:error, :not_found}
      song -> {:ok, song}
    end
  end

  @doc """
  Creates a song.

  ## Examples

      iex> create_song(%{field: value})
      {:ok, %Song{}}

      iex> create_song(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_song(attrs \\ %{}) do
    %Song{}
    |> Song.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a song.

  ## Examples

      iex> update_song(song, %{field: new_value})
      {:ok, %Song{}}

      iex> update_song(song, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_song(%Song{} = song, attrs) do
    song
    |> Song.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a song.

  ## Examples

      iex> delete_song(song)
      {:ok, %Song{}}

      iex> delete_song(song)
      {:error, %Ecto.Changeset{}}

  """
  def delete_song(%Song{} = song) do
    Repo.delete(song)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking song changes.

  ## Examples

      iex> change_song(song)
      %Ecto.Changeset{data: %Song{}}

  """
  def change_song(%Song{} = song, attrs \\ %{}) do
    Song.changeset(song, attrs)
  end

  @doc """
  Returns the list of genres.

  ## Examples

      iex> list_genres()
      [%Genre{}, ...]

  """
  def list_genres do
    query = from genre in Genre, order_by: genre.name
    Repo.all(query)
  end

  @doc """
  Gets a single genre.

  Raises `Ecto.NoResultsError` if the Genre does not exist.

  ## Examples

      iex> get_genre!(123)
      %Genre{}

      iex> get_genre!(456)
      ** (Ecto.NoResultsError)

  """
  def get_genre!(id), do: Repo.get!(Genre, id)

  @doc """
  Creates a genre.

  ## Examples

      iex> create_genre(%{field: value})
      {:ok, %Genre{}}

      iex> create_genre(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_genre(attrs \\ %{}) do
    %Genre{}
    |> Genre.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def get_or_create_genre(attrs \\ %{}) do
    genre = from(g in Genre, where: g.name == ^attrs["name"]) |> Repo.one()

    case genre do
      nil ->
        %Genre{}
        |> Genre.changeset(attrs)
        |> Repo.insert()

      genre ->
        {:ok, genre}
    end
  end

  @doc """
  Updates a genre.

  ## Examples

      iex> update_genre(genre, %{field: new_value})
      {:ok, %Genre{}}

      iex> update_genre(genre, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_genre(%Genre{} = genre, attrs) do
    genre
    |> Genre.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a genre.

  ## Examples

      iex> delete_genre(genre)
      {:ok, %Genre{}}

      iex> delete_genre(genre)
      {:error, %Ecto.Changeset{}}

  """
  def delete_genre(%Genre{} = genre) do
    Repo.delete(genre)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking genre changes.

  ## Examples

      iex> change_genre(genre)
      %Ecto.Changeset{data: %Genre{}}

  """
  def change_genre(%Genre{} = genre, attrs \\ %{}) do
    Genre.changeset(genre, attrs)
  end

  @doc """
  Automatically pick a song with the artist of the same genre
  as the station
  """
  def random_song(station) do
    artist =
      list_artists_in_genres(station.genres)
      |> Enum.random()

    album =
      list_albums_for_artist_in_genres(artist, station.genres)
      |> Enum.random()

    from(song in Song,
      where: song.album_id == ^album.id,
      order_by: fragment("RANDOM()"),
      limit: 10
    )
    |> Repo.all()
    |> Enum.random()
  end
end
