defmodule RadioWeb.StationLive.ShowComponent do
  use RadioWeb, :live_component

  alias Radio.Broadcasts

  @impl true
  def update(%{station: station} = assigns, socket) do
    history = Broadcasts.get_station_history(station)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(station: Broadcasts.load_genres(station), history: history)}
  end
end
