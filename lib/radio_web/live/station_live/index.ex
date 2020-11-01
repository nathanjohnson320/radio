defmodule RadioWeb.StationLive.Index do
  use RadioWeb, :live_view

  alias Radio.{Broadcasts, Media, Repo}
  alias Radio.Broadcasts.{PlayItem, Station, Registry}
  alias Radio.Station, as: RadioStation
  alias RadioWeb.Endpoint

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     assign(socket,
       current_station: nil,
       playing: nil,
       now_playing: nil,
       current_user: session["current_user_id"]
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :queue, %{"id" => id}) do
    station = Broadcasts.get_station!(id)

    socket
    |> assign(:page_title, "Station Queue")
    |> assign(:station, station)
    |> assign(:play_item, %PlayItem{station_id: station.id})
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    station = Broadcasts.get_station!(id)

    socket
    |> assign(:page_title, station.name)
    |> assign(:station, station)
  end

  defp apply_action(socket, :album_show, %{"id" => id}) do
    album = Media.get_album!(id)

    socket
    |> assign(:page_title, album.title)
    |> assign(:album, album)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Station")
    |> assign(:station, Broadcasts.get_station!(id, [:genres]))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Station")
    |> assign(:station, %Station{genres: []})
  end

  defp apply_action(socket, :index, _params) do
    stations =
      Enum.map(Broadcasts.list_stations(), fn station ->
        :ok = Endpoint.subscribe("station:#{station.id}:update")
        {pid, _} = Registry.lookup!(station)

        case RadioStation.now_playing(pid) do
          nil ->
            station

          {_pid, play_item} ->
            play_item = Repo.preload(play_item, song: [album: [:artist]])
            Map.put_new(station, :now_playing, play_item)
        end
      end)

    socket
    |> assign(:page_title, "Listing Stations")
    |> assign(:station, nil)
    |> assign(:stations, stations)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    station = Broadcasts.get_station!(id)
    {:ok, _} = Broadcasts.delete_station(station)

    {:noreply, assign(socket, :stations, Broadcasts.list_stations())}
  end

  @impl true
  def handle_event(
        "play",
        %{"id" => id},
        %{assigns: %{stations: stations, current_user: current_user}} = socket
      ) do
    current_station = Enum.find(stations, &(to_string(&1.id) == id))

    Endpoint.broadcast!("#{current_user}:player", "play", %{data: current_station})

    {:noreply,
     socket
     |> assign(current_station: current_station)}
  end

  @impl true
  def handle_info(
        %{event: "song_change", payload: %{data: station}},
        %{assigns: %{stations: stations}} = socket
      ) do
    {pid, _} = Registry.lookup!(station)

    case RadioStation.now_playing(pid) do
      nil ->
        {:noreply, socket}

      {_pid, play_item} ->
        {:noreply,
         socket
         |> assign(
           stations:
             Enum.map(stations, fn s ->
               if station.id == s.id do
                 play_item = Repo.preload(play_item, song: [album: [:artist]])
                 Map.put(station, :now_playing, play_item)
               else
                 s
               end
             end)
         )}
    end
  end
end