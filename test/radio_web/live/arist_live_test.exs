defmodule RadioWeb.ArtistLiveTest do
  use RadioWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Radio.Media

  @create_attrs %{art: "some art", country: [], genre: [], guid: "some guid", index: 42, key: "some key", name: "some name", rating_key: "some rating_key", summary: "some summary", thumb: "some thumb"}
  @update_attrs %{art: "some updated art", country: [], genre: [], guid: "some updated guid", index: 43, key: "some updated key", name: "some updated name", rating_key: "some updated rating_key", summary: "some updated summary", thumb: "some updated thumb"}
  @invalid_attrs %{art: nil, country: nil, genre: nil, guid: nil, index: nil, key: nil, name: nil, rating_key: nil, summary: nil, thumb: nil}

  defp fixture(:artist) do
    {:ok, artist} = Media.create_artist(@create_attrs)
    artist
  end

  defp create_artist(_) do
    artist = fixture(:artist)
    %{artist: artist}
  end

  describe "Index" do
    setup [:create_artist]

    test "lists all artists", %{conn: conn, artist: artist} do
      {:ok, _index_live, html} = live(conn, Routes.artist_index_path(conn, :index))

      assert html =~ "Listing Artists"
      assert html =~ artist.art
    end

    test "saves new artist", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.artist_index_path(conn, :index))

      assert index_live |> element("a", "New Artist") |> render_click() =~
               "New Artist"

      assert_patch(index_live, Routes.artist_index_path(conn, :new))

      assert index_live
             |> form("#artist-form", artist: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#artist-form", artist: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.artist_index_path(conn, :index))

      assert html =~ "Artist created successfully"
      assert html =~ "some art"
    end

    test "updates artist in listing", %{conn: conn, artist: artist} do
      {:ok, index_live, _html} = live(conn, Routes.artist_index_path(conn, :index))

      assert index_live |> element("#artist-#{artist.id} a", "Edit") |> render_click() =~
               "Edit Artist"

      assert_patch(index_live, Routes.artist_index_path(conn, :edit, artist))

      assert index_live
             |> form("#artist-form", artist: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#artist-form", artist: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.artist_index_path(conn, :index))

      assert html =~ "Artist updated successfully"
      assert html =~ "some updated art"
    end

    test "deletes artist in listing", %{conn: conn, artist: artist} do
      {:ok, index_live, _html} = live(conn, Routes.artist_index_path(conn, :index))

      assert index_live |> element("#artist-#{artist.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#artist-#{artist.id}")
    end
  end

  describe "Show" do
    setup [:create_artist]

    test "displays artist", %{conn: conn, artist: artist} do
      {:ok, _show_live, html} = live(conn, Routes.artist_show_path(conn, :show, artist))

      assert html =~ "Show Artist"
      assert html =~ artist.art
    end

    test "updates artist within modal", %{conn: conn, artist: artist} do
      {:ok, show_live, _html} = live(conn, Routes.artist_show_path(conn, :show, artist))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Artist"

      assert_patch(show_live, Routes.artist_show_path(conn, :edit, artist))

      assert show_live
             |> form("#artist-form", artist: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#artist-form", artist: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.artist_show_path(conn, :show, artist))

      assert html =~ "Artist updated successfully"
      assert html =~ "some updated art"
    end
  end
end
