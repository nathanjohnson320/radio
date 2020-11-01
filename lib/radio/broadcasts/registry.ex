defmodule Radio.Broadcasts.Registry do
  alias Radio.Broadcasts.Station

  def register(%Station{} = station) do
    Registry.register(StationRegistry, station.id, station)
  end

  def lookup(%{id: id}) do
    case Registry.lookup(StationRegistry, id) do
      [] -> {:error, :not_registered}
      [station] -> {:ok, station}
    end
  end

  def lookup!(%{id: id}) do
    case Registry.lookup(StationRegistry, id) do
      [] -> raise "station #{id} has not started!"
      [station] -> station
    end
  end
end
