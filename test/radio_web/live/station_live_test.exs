defmodule RadioWeb.StationLiveTest do
  use RadioWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Radio.Broadcasts

  @create_attrs %{genre: [], name: "some name"}
  @update_attrs %{genre: [], name: "some updated name"}
  @invalid_attrs %{genre: nil, name: nil}

  defp fixture(:station) do
    {:ok, station} = Broadcasts.create_station(@create_attrs)
    station
  end

  defp create_station(_) do
    station = fixture(:station)
    %{station: station}
  end

  describe "Index" do
    setup [:create_station]

    test "lists all stations", %{conn: conn, station: station} do
      {:ok, _index_live, html} = live(conn, Routes.station_index_path(conn, :index))

      assert html =~ "Listing Stations"
      assert html =~ station.genre
    end

    test "saves new station", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.station_index_path(conn, :index))

      assert index_live |> element("a", "New Station") |> render_click() =~
               "New Station"

      assert_patch(index_live, Routes.station_index_path(conn, :new))

      assert index_live
             |> form("#station-form", station: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#station-form", station: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.station_index_path(conn, :index))

      assert html =~ "Station created successfully"
      assert html =~ "some genre"
    end

    test "updates station in listing", %{conn: conn, station: station} do
      {:ok, index_live, _html} = live(conn, Routes.station_index_path(conn, :index))

      assert index_live |> element("#station-#{station.id} a", "Edit") |> render_click() =~
               "Edit Station"

      assert_patch(index_live, Routes.station_index_path(conn, :edit, station))

      assert index_live
             |> form("#station-form", station: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#station-form", station: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.station_index_path(conn, :index))

      assert html =~ "Station updated successfully"
      assert html =~ "some updated genre"
    end

    test "deletes station in listing", %{conn: conn, station: station} do
      {:ok, index_live, _html} = live(conn, Routes.station_index_path(conn, :index))

      assert index_live |> element("#station-#{station.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#station-#{station.id}")
    end
  end

  describe "Show" do
    setup [:create_station]

    test "displays station", %{conn: conn, station: station} do
      {:ok, _show_live, html} = live(conn, Routes.station_show_path(conn, :show, station))

      assert html =~ "Show Station"
      assert html =~ station.genre
    end

    test "updates station within modal", %{conn: conn, station: station} do
      {:ok, show_live, _html} = live(conn, Routes.station_show_path(conn, :show, station))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Station"

      assert_patch(show_live, Routes.station_show_path(conn, :edit, station))

      assert show_live
             |> form("#station-form", station: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#station-form", station: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.station_show_path(conn, :show, station))

      assert html =~ "Station updated successfully"
      assert html =~ "some updated genre"
    end
  end
end
