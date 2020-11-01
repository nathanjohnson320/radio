defmodule Radio.Broadcasts do
  @moduledoc """
  The Broadcasts context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Radio.Repo

  alias Radio.Broadcasts.{PlayItem, Station}
  alias Radio.Broadcasts.Supervisor, as: StationSupervisor
  alias Radio.Media.Genre

  @doc """
  Returns the list of stations.

  ## Examples

      iex> list_stations()
      [%Station{}, ...]

  """
  def list_stations do
    from(station in Station,
      where: station.active
    )
    |> Repo.all()
    |> Repo.preload(:genres)
  end

  def boot_stations() do
    list_stations()
    |> Enum.map(&StationSupervisor.start_child(Radio.Station, %{station: &1}))
  end

  def boot_station(station) do
    StationSupervisor.start_child(Radio.Station, %{station: station})
  end

  def load_genres(station) do
    Repo.preload(station, :genres)
  end

  @doc """
  Gets a single station.

  Raises `Ecto.NoResultsError` if the Station does not exist.

  ## Examples

      iex> get_station!(123)
      %Station{}

      iex> get_station!(456)
      ** (Ecto.NoResultsError)

  """
  def get_station!(id, preloads \\ []) do
    Repo.get!(Station, id) |> Repo.preload(preloads)
  end

  def get_station_history(station, limit \\ 20) do
    from(station in Station,
      join: play_items in assoc(station, :play_items),
      where: station.id == ^station.id and play_items.played,
      limit: ^limit,
      order_by: [desc: play_items.inserted_at],
      select: play_items
    )
    |> Repo.all()
    |> Repo.preload(song: [album: [:artist]])
  end

  @doc """
  Creates a station.

  ## Examples

      iex> create_station(%{field: value})
      {:ok, %Station{}}

      iex> create_station(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_station(attrs \\ %{}) do
    genres =
      if not is_nil(attrs["genre"]) do
        from(g in Genre, where: g.id in ^attrs["genre"]) |> Repo.all()
      else
        []
      end

    %Station{}
    |> Station.changeset(attrs, genres)
    |> Repo.insert()
  end

  @doc """
  Updates a station.

  ## Examples

      iex> update_station(station, %{field: new_value})
      {:ok, %Station{}}

      iex> update_station(station, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_station(%Station{} = station, attrs) do
    genres =
      if not is_nil(attrs["genre"]) do
        from(g in Genre, where: g.id in ^attrs["genre"]) |> Repo.all()
      else
        []
      end

    station
    |> Station.changeset(attrs, genres)
    |> Repo.update()
  end

  @doc """
  Deletes a station.

  ## Examples

      iex> delete_station(station)
      {:ok, %Station{}}

      iex> delete_station(station)
      {:error, %Ecto.Changeset{}}

  """
  def delete_station(%Station{} = station) do
    Repo.delete(station)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking station changes.

  ## Examples

      iex> change_station(station)
      %Ecto.Changeset{data: %Station{}}

  """
  def change_station(%Station{} = station, attrs \\ %{}) do
    station = station |> Repo.preload(:genres)
    Station.changeset(station, attrs, station.genres)
  end

  @doc """
  Returns the list of play_items.

  ## Examples

      iex> list_play_items()
      [%PlayItem{}, ...]

  """
  def list_play_items do
    Repo.all(PlayItem)
  end

  def list_station_play_items(station) do
    from(play_item in PlayItem,
      join: song in assoc(play_item, :song),
      preload: [:song],
      where: play_item.station_id == ^station.id and not play_item.played
    )
    |> Repo.all()
  end

  @doc """
  Gets a single play_item.

  Raises `Ecto.NoResultsError` if the Play item does not exist.

  ## Examples

      iex> get_play_item!(123)
      %PlayItem{}

      iex> get_play_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_play_item!(id), do: Repo.get!(PlayItem, id)

  def create_play_item(play_item, attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:play_item, PlayItem.changeset(play_item, attrs))
    |> Repo.transaction()
  end

  @doc """
  Updates a play_item.

  ## Examples

      iex> update_play_item(play_item, %{field: new_value})
      {:ok, %PlayItem{}}

      iex> update_play_item(play_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_play_item(%PlayItem{} = play_item, attrs) do
    play_item
    |> PlayItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a play_item.

  ## Examples

      iex> delete_play_item(play_item)
      {:ok, %PlayItem{}}

      iex> delete_play_item(play_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_play_item(%PlayItem{} = play_item) do
    Repo.delete(play_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking play_item changes.

  ## Examples

      iex> change_play_item(play_item)
      %Ecto.Changeset{data: %PlayItem{}}

  """
  def change_play_item(%PlayItem{} = play_item, attrs \\ %{}) do
    PlayItem.changeset(play_item, attrs)
  end
end
