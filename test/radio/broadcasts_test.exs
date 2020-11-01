defmodule Radio.BroadcastsTest do
  use Radio.DataCase

  alias Radio.Broadcasts

  describe "stations" do
    alias Radio.Broadcasts.Station

    @valid_attrs %{genre: [], name: "some name"}
    @update_attrs %{genre: [], name: "some updated name"}
    @invalid_attrs %{genre: nil, name: nil}

    def station_fixture(attrs \\ %{}) do
      {:ok, station} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Broadcasts.create_station()

      station
    end

    test "list_stations/0 returns all stations" do
      station = station_fixture()
      assert Broadcasts.list_stations() == [station]
    end

    test "get_station!/1 returns the station with given id" do
      station = station_fixture()
      assert Broadcasts.get_station!(station.id) == station
    end

    test "create_station/1 with valid data creates a station" do
      assert {:ok, %Station{} = station} = Broadcasts.create_station(@valid_attrs)
      assert station.genre == []
      assert station.name == "some name"
    end

    test "create_station/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Broadcasts.create_station(@invalid_attrs)
    end

    test "update_station/2 with valid data updates the station" do
      station = station_fixture()
      assert {:ok, %Station{} = station} = Broadcasts.update_station(station, @update_attrs)
      assert station.genre == []
      assert station.name == "some updated name"
    end

    test "update_station/2 with invalid data returns error changeset" do
      station = station_fixture()
      assert {:error, %Ecto.Changeset{}} = Broadcasts.update_station(station, @invalid_attrs)
      assert station == Broadcasts.get_station!(station.id)
    end

    test "delete_station/1 deletes the station" do
      station = station_fixture()
      assert {:ok, %Station{}} = Broadcasts.delete_station(station)
      assert_raise Ecto.NoResultsError, fn -> Broadcasts.get_station!(station.id) end
    end

    test "change_station/1 returns a station changeset" do
      station = station_fixture()
      assert %Ecto.Changeset{} = Broadcasts.change_station(station)
    end
  end

  describe "play_items" do
    alias Radio.Broadcasts.PlayItem

    @valid_attrs %{play_time: "2010-04-17T14:00:00Z", played: true}
    @update_attrs %{play_time: "2011-05-18T15:01:01Z", played: false}
    @invalid_attrs %{play_time: nil, played: nil}

    def play_item_fixture(attrs \\ %{}) do
      {:ok, play_item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Broadcasts.create_play_item()

      play_item
    end

    test "list_play_items/0 returns all play_items" do
      play_item = play_item_fixture()
      assert Broadcasts.list_play_items() == [play_item]
    end

    test "get_play_item!/1 returns the play_item with given id" do
      play_item = play_item_fixture()
      assert Broadcasts.get_play_item!(play_item.id) == play_item
    end

    test "create_play_item/1 with valid data creates a play_item" do
      assert {:ok, %PlayItem{} = play_item} = Broadcasts.create_play_item(@valid_attrs)
      assert play_item.play_time == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert play_item.played == true
    end

    test "create_play_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Broadcasts.create_play_item(@invalid_attrs)
    end

    test "update_play_item/2 with valid data updates the play_item" do
      play_item = play_item_fixture()
      assert {:ok, %PlayItem{} = play_item} = Broadcasts.update_play_item(play_item, @update_attrs)
      assert play_item.play_time == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert play_item.played == false
    end

    test "update_play_item/2 with invalid data returns error changeset" do
      play_item = play_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Broadcasts.update_play_item(play_item, @invalid_attrs)
      assert play_item == Broadcasts.get_play_item!(play_item.id)
    end

    test "delete_play_item/1 deletes the play_item" do
      play_item = play_item_fixture()
      assert {:ok, %PlayItem{}} = Broadcasts.delete_play_item(play_item)
      assert_raise Ecto.NoResultsError, fn -> Broadcasts.get_play_item!(play_item.id) end
    end

    test "change_play_item/1 returns a play_item changeset" do
      play_item = play_item_fixture()
      assert %Ecto.Changeset{} = Broadcasts.change_play_item(play_item)
    end
  end
end
