defmodule RadioWeb.StationLive.FormComponent do
  use RadioWeb, :live_component

  alias Radio.Broadcasts
  alias Radio.Media

  @impl true
  def update(%{station: station} = assigns, socket) do
    changeset = Broadcasts.change_station(station)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:genres, Media.list_genres())
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"station" => station_params}, socket) do
    changeset =
      socket.assigns.station
      |> Broadcasts.change_station(station_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"station" => station_params}, socket) do
    save_station(socket, socket.assigns.action, station_params)
  end

  defp save_station(socket, :edit, station_params) do
    case Broadcasts.update_station(socket.assigns.station, station_params) do
      {:ok, _station} ->
        {:noreply,
         socket
         |> put_flash(:info, "Station updated successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_station(socket, :new, station_params) do
    case Broadcasts.create_station(station_params) do
      {:ok, station} ->
        {:ok, _pid} = Broadcasts.boot_station(station)

        {:noreply,
         socket
         |> put_flash(:info, "Station created successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def genres(genres) do
    Enum.map(genres, &{&1.name, &1.id})
  end
end
