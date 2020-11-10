defmodule RadioWeb.AudioPlayer do
  use RadioWeb, :live_view

  alias Radio.Broadcasts.Registry
  alias Radio.Repo
  alias Radio.Station
  alias RadioWeb.Endpoint

  @impl true
  def mount(_params, %{"current_user_id" => current_user}, socket) do
    :ok = Endpoint.subscribe("#{current_user}:player")

    local_addr = get_local_addr()

    {:ok,
     assign(socket,
       current_station: nil,
       playing: nil,
       now_playing: nil,
       current_user: current_user,
       local_addr: local_addr
     )}
  end

  @impl true
  def handle_event("toggle_playing", %{"playing" => playing}, socket) do
    {:noreply, socket |> assign(playing: playing)}
  end

  @impl true
  def handle_info(
        %{event: "play", payload: %{data: station}},
        %{assigns: %{current_station: current_station}} = socket
      ) do
    :ok =
      if not is_nil(current_station),
        do: Endpoint.unsubscribe("station:#{current_station.id}:update"),
        else: :ok

    {pid, _station} = Registry.lookup!(station)
    :ok = Endpoint.subscribe("station:#{station.id}:update")

    case Station.now_playing(pid) do
      nil ->
        {:noreply, socket |> assign(playing: false, current_station: station)}

      {_pid, play_item} ->
        play_item = Repo.preload(play_item, song: [album: [:artist]])

        {:noreply,
         socket |> assign(now_playing: play_item, playing: true, current_station: station)}
    end
  end

  @impl true
  def handle_info(
        %{event: "song_change", payload: %{data: station}},
        socket
      ) do
    {pid, _} = Registry.lookup!(station)

    case Station.now_playing(pid) do
      nil ->
        {:noreply, socket |> assign(playing: false, current_station: station)}

      {_pid, play_item} ->
        play_item = Repo.preload(play_item, song: [album: [:artist]])

        {:noreply,
         socket |> assign(now_playing: play_item, playing: true, current_station: station)}
    end
  end

  defp get_local_addr() do
    {:ok, ips} = :inet.getif()

    {{a, b, c, d}, _, _} =
      Enum.find(
        ips,
        fn
          {{192, 168, _, _}, _, _} ->
            true

          _ ->
            false
        end
      )

    Enum.join([a, b, c, d], ".")
  end
end
