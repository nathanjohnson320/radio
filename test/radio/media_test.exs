defmodule Radio.MediaTest do
  use Radio.DataCase

  alias Radio.Media

  describe "artists" do
    alias Radio.Media.Artist

    @valid_attrs %{art: "some art", country: [], genre: [], guid: "some guid", index: 42, key: "some key", name: "some name", rating_key: "some rating_key", summary: "some summary", thumb: "some thumb"}
    @update_attrs %{art: "some updated art", country: [], genre: [], guid: "some updated guid", index: 43, key: "some updated key", name: "some updated name", rating_key: "some updated rating_key", summary: "some updated summary", thumb: "some updated thumb"}
    @invalid_attrs %{art: nil, country: nil, genre: nil, guid: nil, index: nil, key: nil, name: nil, rating_key: nil, summary: nil, thumb: nil}

    def artist_fixture(attrs \\ %{}) do
      {:ok, artist} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Media.create_artist()

      artist
    end

    test "list_artists/0 returns all artists" do
      artist = artist_fixture()
      assert Media.list_artists() == [artist]
    end

    test "get_artist!/1 returns the artist with given id" do
      artist = artist_fixture()
      assert Media.get_artist!(artist.id) == artist
    end

    test "create_artist/1 with valid data creates a artist" do
      assert {:ok, %Artist{} = artist} = Media.create_artist(@valid_attrs)
      assert artist.art == "some art"
      assert artist.country == []
      assert artist.genre == []
      assert artist.guid == "some guid"
      assert artist.index == 42
      assert artist.key == "some key"
      assert artist.name == "some name"
      assert artist.rating_key == "some rating_key"
      assert artist.summary == "some summary"
      assert artist.thumb == "some thumb"
    end

    test "create_artist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_artist(@invalid_attrs)
    end

    test "update_artist/2 with valid data updates the artist" do
      artist = artist_fixture()
      assert {:ok, %Artist{} = artist} = Media.update_artist(artist, @update_attrs)
      assert artist.art == "some updated art"
      assert artist.country == []
      assert artist.genre == []
      assert artist.guid == "some updated guid"
      assert artist.index == 43
      assert artist.key == "some updated key"
      assert artist.name == "some updated name"
      assert artist.rating_key == "some updated rating_key"
      assert artist.summary == "some updated summary"
      assert artist.thumb == "some updated thumb"
    end

    test "update_artist/2 with invalid data returns error changeset" do
      artist = artist_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_artist(artist, @invalid_attrs)
      assert artist == Media.get_artist!(artist.id)
    end

    test "delete_artist/1 deletes the artist" do
      artist = artist_fixture()
      assert {:ok, %Artist{}} = Media.delete_artist(artist)
      assert_raise Ecto.NoResultsError, fn -> Media.get_artist!(artist.id) end
    end

    test "change_artist/1 returns a artist changeset" do
      artist = artist_fixture()
      assert %Ecto.Changeset{} = Media.change_artist(artist)
    end
  end

  describe "albums" do
    alias Radio.Media.Album

    @valid_attrs %{art: "some art", director: [], genre: [], guid: "some guid", index: 42, key: "some key", studio: "some studio", summary: "some summary", thumb: "some thumb", title: "some title", year: 42}
    @update_attrs %{art: "some updated art", director: [], genre: [], guid: "some updated guid", index: 43, key: "some updated key", studio: "some updated studio", summary: "some updated summary", thumb: "some updated thumb", title: "some updated title", year: 43}
    @invalid_attrs %{art: nil, director: nil, genre: nil, guid: nil, index: nil, key: nil, studio: nil, summary: nil, thumb: nil, title: nil, year: nil}

    def album_fixture(attrs \\ %{}) do
      {:ok, album} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Media.create_album()

      album
    end

    test "list_albums/0 returns all albums" do
      album = album_fixture()
      assert Media.list_albums() == [album]
    end

    test "get_album!/1 returns the album with given id" do
      album = album_fixture()
      assert Media.get_album!(album.id) == album
    end

    test "create_album/1 with valid data creates a album" do
      assert {:ok, %Album{} = album} = Media.create_album(@valid_attrs)
      assert album.art == "some art"
      assert album.director == []
      assert album.genre == []
      assert album.guid == "some guid"
      assert album.index == 42
      assert album.key == "some key"
      assert album.studio == "some studio"
      assert album.summary == "some summary"
      assert album.thumb == "some thumb"
      assert album.title == "some title"
      assert album.year == 42
    end

    test "create_album/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_album(@invalid_attrs)
    end

    test "update_album/2 with valid data updates the album" do
      album = album_fixture()
      assert {:ok, %Album{} = album} = Media.update_album(album, @update_attrs)
      assert album.art == "some updated art"
      assert album.director == []
      assert album.genre == []
      assert album.guid == "some updated guid"
      assert album.index == 43
      assert album.key == "some updated key"
      assert album.studio == "some updated studio"
      assert album.summary == "some updated summary"
      assert album.thumb == "some updated thumb"
      assert album.title == "some updated title"
      assert album.year == 43
    end

    test "update_album/2 with invalid data returns error changeset" do
      album = album_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_album(album, @invalid_attrs)
      assert album == Media.get_album!(album.id)
    end

    test "delete_album/1 deletes the album" do
      album = album_fixture()
      assert {:ok, %Album{}} = Media.delete_album(album)
      assert_raise Ecto.NoResultsError, fn -> Media.get_album!(album.id) end
    end

    test "change_album/1 returns a album changeset" do
      album = album_fixture()
      assert %Ecto.Changeset{} = Media.change_album(album)
    end
  end

  describe "songs" do
    alias Radio.Media.Song

    @valid_attrs %{art: "some art", audio_channels: 42, audio_codec: "some audio_codec", bitrate: 42, container: "some container", duration: 42, file: "some file", guid: "some guid", index: 42, key: "some key", size: 42, summary: "some summary", thumb: "some thumb", title: "some title"}
    @update_attrs %{art: "some updated art", audio_channels: 43, audio_codec: "some updated audio_codec", bitrate: 43, container: "some updated container", duration: 43, file: "some updated file", guid: "some updated guid", index: 43, key: "some updated key", size: 43, summary: "some updated summary", thumb: "some updated thumb", title: "some updated title"}
    @invalid_attrs %{art: nil, audio_channels: nil, audio_codec: nil, bitrate: nil, container: nil, duration: nil, file: nil, guid: nil, index: nil, key: nil, size: nil, summary: nil, thumb: nil, title: nil}

    def song_fixture(attrs \\ %{}) do
      {:ok, song} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Media.create_song()

      song
    end

    test "list_songs/0 returns all songs" do
      song = song_fixture()
      assert Media.list_songs() == [song]
    end

    test "get_song!/1 returns the song with given id" do
      song = song_fixture()
      assert Media.get_song!(song.id) == song
    end

    test "create_song/1 with valid data creates a song" do
      assert {:ok, %Song{} = song} = Media.create_song(@valid_attrs)
      assert song.art == "some art"
      assert song.audio_channels == 42
      assert song.audio_codec == "some audio_codec"
      assert song.bitrate == 42
      assert song.container == "some container"
      assert song.duration == 42
      assert song.file == "some file"
      assert song.guid == "some guid"
      assert song.index == 42
      assert song.key == "some key"
      assert song.size == 42
      assert song.summary == "some summary"
      assert song.thumb == "some thumb"
      assert song.title == "some title"
    end

    test "create_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_song(@invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = song_fixture()
      assert {:ok, %Song{} = song} = Media.update_song(song, @update_attrs)
      assert song.art == "some updated art"
      assert song.audio_channels == 43
      assert song.audio_codec == "some updated audio_codec"
      assert song.bitrate == 43
      assert song.container == "some updated container"
      assert song.duration == 43
      assert song.file == "some updated file"
      assert song.guid == "some updated guid"
      assert song.index == 43
      assert song.key == "some updated key"
      assert song.size == 43
      assert song.summary == "some updated summary"
      assert song.thumb == "some updated thumb"
      assert song.title == "some updated title"
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_song(song, @invalid_attrs)
      assert song == Media.get_song!(song.id)
    end

    test "delete_song/1 deletes the song" do
      song = song_fixture()
      assert {:ok, %Song{}} = Media.delete_song(song)
      assert_raise Ecto.NoResultsError, fn -> Media.get_song!(song.id) end
    end

    test "change_song/1 returns a song changeset" do
      song = song_fixture()
      assert %Ecto.Changeset{} = Media.change_song(song)
    end
  end

  describe "genres" do
    alias Radio.Media.Genre

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def genre_fixture(attrs \\ %{}) do
      {:ok, genre} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Media.create_genre()

      genre
    end

    test "list_genres/0 returns all genres" do
      genre = genre_fixture()
      assert Media.list_genres() == [genre]
    end

    test "get_genre!/1 returns the genre with given id" do
      genre = genre_fixture()
      assert Media.get_genre!(genre.id) == genre
    end

    test "create_genre/1 with valid data creates a genre" do
      assert {:ok, %Genre{} = genre} = Media.create_genre(@valid_attrs)
      assert genre.name == "some name"
    end

    test "create_genre/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_genre(@invalid_attrs)
    end

    test "update_genre/2 with valid data updates the genre" do
      genre = genre_fixture()
      assert {:ok, %Genre{} = genre} = Media.update_genre(genre, @update_attrs)
      assert genre.name == "some updated name"
    end

    test "update_genre/2 with invalid data returns error changeset" do
      genre = genre_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_genre(genre, @invalid_attrs)
      assert genre == Media.get_genre!(genre.id)
    end

    test "delete_genre/1 deletes the genre" do
      genre = genre_fixture()
      assert {:ok, %Genre{}} = Media.delete_genre(genre)
      assert_raise Ecto.NoResultsError, fn -> Media.get_genre!(genre.id) end
    end

    test "change_genre/1 returns a genre changeset" do
      genre = genre_fixture()
      assert %Ecto.Changeset{} = Media.change_genre(genre)
    end
  end
end
