defmodule RadioWeb.AlbumLiveTest do
  use RadioWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Radio.Media

  @create_attrs %{art: "some art", director: [], genre: [], guid: "some guid", index: 42, key: "some key", studio: "some studio", summary: "some summary", thumb: "some thumb", title: "some title", year: 42}
  @update_attrs %{art: "some updated art", director: [], genre: [], guid: "some updated guid", index: 43, key: "some updated key", studio: "some updated studio", summary: "some updated summary", thumb: "some updated thumb", title: "some updated title", year: 43}
  @invalid_attrs %{art: nil, director: nil, genre: nil, guid: nil, index: nil, key: nil, studio: nil, summary: nil, thumb: nil, title: nil, year: nil}

  defp fixture(:album) do
    {:ok, album} = Media.create_album(@create_attrs)
    album
  end

  defp create_album(_) do
    album = fixture(:album)
    %{album: album}
  end

  describe "Index" do
    setup [:create_album]

    test "lists all albums", %{conn: conn, album: album} do
      {:ok, _index_live, html} = live(conn, Routes.album_index_path(conn, :index))

      assert html =~ "Listing Albums"
      assert html =~ album.art
    end

    test "saves new album", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.album_index_path(conn, :index))

      assert index_live |> element("a", "New Album") |> render_click() =~
               "New Album"

      assert_patch(index_live, Routes.album_index_path(conn, :new))

      assert index_live
             |> form("#album-form", album: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#album-form", album: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.album_index_path(conn, :index))

      assert html =~ "Album created successfully"
      assert html =~ "some art"
    end

    test "updates album in listing", %{conn: conn, album: album} do
      {:ok, index_live, _html} = live(conn, Routes.album_index_path(conn, :index))

      assert index_live |> element("#album-#{album.id} a", "Edit") |> render_click() =~
               "Edit Album"

      assert_patch(index_live, Routes.album_index_path(conn, :edit, album))

      assert index_live
             |> form("#album-form", album: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#album-form", album: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.album_index_path(conn, :index))

      assert html =~ "Album updated successfully"
      assert html =~ "some updated art"
    end

    test "deletes album in listing", %{conn: conn, album: album} do
      {:ok, index_live, _html} = live(conn, Routes.album_index_path(conn, :index))

      assert index_live |> element("#album-#{album.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#album-#{album.id}")
    end
  end

  describe "Show" do
    setup [:create_album]

    test "displays album", %{conn: conn, album: album} do
      {:ok, _show_live, html} = live(conn, Routes.album_show_path(conn, :show, album))

      assert html =~ "Show Album"
      assert html =~ album.art
    end

    test "updates album within modal", %{conn: conn, album: album} do
      {:ok, show_live, _html} = live(conn, Routes.album_show_path(conn, :show, album))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Album"

      assert_patch(show_live, Routes.album_show_path(conn, :edit, album))

      assert show_live
             |> form("#album-form", album: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#album-form", album: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.album_show_path(conn, :show, album))

      assert html =~ "Album updated successfully"
      assert html =~ "some updated art"
    end
  end
end
