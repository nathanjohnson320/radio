defmodule RadioWeb.StationLive.PickerComponent do
  use RadioWeb, :live_component

  alias Radio.{Broadcasts, Media}
  alias Radio.Broadcasts.Registry, as: StationRegistry

  @impl true
  def preload(list_of_assigns) do
    Enum.map(list_of_assigns, fn assigns ->
      station = Broadcasts.load_genres(assigns.station)
      artists = Media.list_artists_in_genres(station.genres)

      assigns
      |> Map.put(:artists, artists)
      |> Map.put(:station, station)
    end)
  end

  @impl true
  def update(%{play_item: play_item} = assigns, socket) do
    changeset = Broadcasts.change_play_item(play_item)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:play_item, play_item)
     |> assign(:selected_artist, nil)
     |> assign(:selected_album, nil)
     |> assign(:selected_song, nil)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"play_item" => play_item_params, "_target" => ["play_item", "artist_id"]},
        %{assigns: %{play_item: play_item, station: station}} = socket
      ) do
    play_item_params = Map.take(play_item_params, ["artist_id"])
    artist = Media.get_artist!(play_item_params["artist_id"])

    {:noreply,
     assign(socket,
       selected_artist: artist,
       selected_album: nil,
       selected_song: nil,
       albums:
         artist
         |> Media.list_albums_for_artist_in_genres(station.genres)
         |> Enum.sort_by(& &1.title),
       changeset: Broadcasts.change_play_item(play_item, play_item_params)
     )}
  end

  @impl true
  def handle_event(
        "validate",
        %{"play_item" => play_item_params, "_target" => ["play_item", "album_id"]},
        %{assigns: %{play_item: play_item}} = socket
      ) do
    play_item_params = Map.take(play_item_params, ["artist_id", "album_id"])

    album = Media.get_album!(play_item_params["album_id"])

    {:noreply,
     assign(socket,
       selected_album: album,
       selected_song: nil,
       songs:
         album
         |> Media.list_songs_for_album(),
       changeset: Broadcasts.change_play_item(play_item, play_item_params)
     )}
  end

  @impl true
  def handle_event(
        "validate",
        %{"play_item" => play_item_params, "_target" => ["play_item", "song_id"]},
        %{assigns: %{play_item: play_item}} = socket
      ) do
    {:noreply,
     assign(socket,
       selected_song: Media.get_song!(play_item_params["song_id"]),
       changeset: Broadcasts.change_play_item(play_item, play_item_params)
     )}
  end

  @impl true
  def handle_event(
        "validate",
        _,
        socket
      ) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "submit",
        %{"play_item" => play_item_params},
        %{assigns: %{play_item: play_item}} = socket
      ) do
    case Broadcasts.create_play_item(play_item, play_item_params) do
      {:ok, %{play_item: play_item}} ->
        {pid, _station} = StationRegistry.lookup!(%{id: play_item.station_id})
        Radio.Station.add_song(pid, play_item)

        {:noreply,
         socket
         |> put_flash(:info, "Song added to queue!")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, :play_item, changeset, _} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  def artists(artists) do
    artists
    |> Enum.map(fn artist ->
      [key: artist.name, value: artist.id]
    end)
  end

  def albums(albums) do
    albums
    |> Enum.map(fn album ->
      [key: album.title, value: album.id]
    end)
  end

  def songs(songs) do
    songs
    |> Enum.map(fn song ->
      [key: song.title, value: song.id]
    end)
  end
end
