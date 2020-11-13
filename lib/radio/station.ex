defmodule Radio.Station do
  use GenServer

  alias Radio.Audio.{Microphone, Pipeline}
  alias Radio.Broadcasts
  alias Radio.Broadcasts.Registry, as: StationRegistry
  alias Radio.Broadcasts.PlayItem
  alias Radio.Media
  alias Radio.Repo
  alias RadioWeb.Endpoint

  # Client Functions

  def add_song(pid, %PlayItem{} = play_item) do
    GenServer.call(pid, {:add_item, play_item})
  end

  def now_playing(pid) do
    GenServer.call(pid, :now_playing)
  end

  def chunk(pid, data) do
    GenServer.call(pid, {:chunk, data}, 100)
  end

  def next(pid, module) do
    send(pid, {:next, module})
  end

  def playing(pid) do
    GenServer.cast(pid, {:playing})
  end

  def start_broadcast(pid) do
    GenServer.call(pid, :microphone_start)
  end

  def stop_broadcast(pid) do
    GenServer.call(pid, :microphone_stop)
  end

  # Server Functions

  @impl true
  def init(state) do
    {:ok, _registry} = StationRegistry.register(state.station)

    queue =
      state.station
      |> Broadcasts.list_station_play_items()
      |> :queue.from_list()

    Process.send_after(self(), {:next, Pipeline}, Enum.random(1..200))
    {:ok, %{station: state.station, queue: queue, now_playing: nil, live: false}}
  end

  @impl true
  def handle_call(:microphone_start, _from, %{now_playing: now_playing, station: station} = state) do
    case now_playing do
      {pid, _play_item} ->
        :ok = Pipeline.stop_and_terminate(pid, blocking: true)

      _ ->
        nil
    end

    {:ok, song} = Radio.Media.get_song_by(key: "live")

    {:ok, %{play_item: play_item}} =
      Broadcasts.create_play_item(%PlayItem{}, %{
        "song_id" => song.id,
        "album_id" => song.album_id,
        "station_id" => station.id
      })

    {:ok, pid} =
      Microphone.start_link(%{
        pid: self(),
        station: station
      })

    :ok = Microphone.play(pid)

    {:reply, :ok, %{state | now_playing: {pid, play_item}, live: true}}
  end

  @impl true
  def handle_call(:microphone_stop, _from, %{now_playing: now_playing} = state) do
    case now_playing do
      {pid, _play_item} ->
        :ok = Microphone.stop_and_terminate(pid, blocking: true)

      _ ->
        nil
    end

    {:reply, :ok, %{state | now_playing: nil}}
  end

  @impl true
  def handle_call(
        {:add_item, play_item},
        _from,
        %{now_playing: nil, station: station} = state
      ) do
    now_playing = start_playing(play_item, station)
    {:reply, :ok, %{state | now_playing: now_playing}}
  end

  @impl true
  def handle_call(
        {:add_item, play_item},
        _from,
        %{queue: queue, now_playing: now_playing} = state
      ) do
    {:reply, :ok, %{state | queue: :queue.in(play_item, queue), now_playing: now_playing}}
  end

  @impl true
  def handle_call(:now_playing, _from, %{now_playing: now_playing} = state) do
    {:reply, now_playing, state}
  end

  @impl true
  def handle_call({:chunk, data}, _from, %{station: station} = state) do
    Endpoint.broadcast_from(self(), to_string(station.id), "input", %{data: data})
    {:reply, :ok, state}
  end

  @impl true
  def handle_info({:next, Pipeline}, %{live: true} = state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:next, module}, %{now_playing: {pid, play_item}} = state) do
    # We were playing something now we want it to stop
    play_item = Broadcasts.get_play_item!(play_item.id)

    {:ok, _play_item} =
      Broadcasts.update_play_item(play_item, %{"played" => true, "end_time" => DateTime.utc_now()})

    apply(module, :stop_and_terminate, [pid, [blocking: true]])

    # Now call the handle again with now_playing nil since we've stopped playing
    handle_info({:next, module}, %{state | now_playing: nil})
  end

  @impl true
  def handle_info({:next, Microphone}, state) do
    state = %{state | live: false}
    {:noreply, next_song_in_queue(state)}
  end

  @impl true
  def handle_info({:next, Pipeline}, %{now_playing: nil} = state) do
    {:noreply, next_song_in_queue(state)}
  end

  @impl true
  def handle_cast({:playing}, %{station: station} = state) do
    Endpoint.broadcast_from(self(), "station:#{station.id}:update", "song_change", %{
      data: station
    })

    {:noreply, state}
  end

  defp next_song_in_queue(%{queue: queue, now_playing: nil, station: station} = state) do
    # Figure out if there's still stuff in the queue, if there is
    # we want to play it otherwise figure out if we should automatically
    # add a song to the queue
    case :queue.out(queue) do
      {:empty, queue} ->
        now_playing =
          if station.auto_play do
            song = Media.random_song(station)

            {:ok, %{play_item: play_item}} =
              Broadcasts.create_play_item(%PlayItem{}, %{
                "song_id" => song.id,
                "album_id" => song.album_id,
                "station_id" => station.id
              })

            start_playing(play_item, station)
          else
            nil
          end

        %{state | queue: queue, now_playing: now_playing}

      {{:value, play_item}, queue} ->
        now_playing = start_playing(play_item, station)
        %{state | queue: queue, now_playing: now_playing}
    end
  end

  defp start_playing(play_item, station) do
    play_item = Broadcasts.get_play_item!(play_item.id)

    {:ok, play_item} =
      Broadcasts.update_play_item(play_item, %{"start_time" => DateTime.utc_now()})

    play_item = Repo.preload(play_item, :song)

    {:ok, pid} =
      Pipeline.start_link(%{
        song: play_item.song,
        pid: self(),
        station: station
      })

    :ok = Pipeline.play(pid)

    {pid, play_item}
  end

  def start_link(_, %{station: station}) do
    GenServer.start_link(__MODULE__, %{
      station: station
    })
  end
end
