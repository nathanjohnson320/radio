defmodule RadioWeb.SongLiveTest do
  use RadioWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Radio.Media

  @create_attrs %{art: "some art", audio_channels: 42, audio_codec: "some audio_codec", bitrate: 42, container: "some container", duration: 42, file: "some file", guid: "some guid", index: 42, key: "some key", size: 42, summary: "some summary", thumb: "some thumb", title: "some title"}
  @update_attrs %{art: "some updated art", audio_channels: 43, audio_codec: "some updated audio_codec", bitrate: 43, container: "some updated container", duration: 43, file: "some updated file", guid: "some updated guid", index: 43, key: "some updated key", size: 43, summary: "some updated summary", thumb: "some updated thumb", title: "some updated title"}
  @invalid_attrs %{art: nil, audio_channels: nil, audio_codec: nil, bitrate: nil, container: nil, duration: nil, file: nil, guid: nil, index: nil, key: nil, size: nil, summary: nil, thumb: nil, title: nil}

  defp fixture(:song) do
    {:ok, song} = Media.create_song(@create_attrs)
    song
  end

  defp create_song(_) do
    song = fixture(:song)
    %{song: song}
  end

  describe "Index" do
    setup [:create_song]

    test "lists all songs", %{conn: conn, song: song} do
      {:ok, _index_live, html} = live(conn, Routes.song_index_path(conn, :index))

      assert html =~ "Listing Songs"
      assert html =~ song.art
    end

    test "saves new song", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.song_index_path(conn, :index))

      assert index_live |> element("a", "New Song") |> render_click() =~
               "New Song"

      assert_patch(index_live, Routes.song_index_path(conn, :new))

      assert index_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#song-form", song: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.song_index_path(conn, :index))

      assert html =~ "Song created successfully"
      assert html =~ "some art"
    end

    test "updates song in listing", %{conn: conn, song: song} do
      {:ok, index_live, _html} = live(conn, Routes.song_index_path(conn, :index))

      assert index_live |> element("#song-#{song.id} a", "Edit") |> render_click() =~
               "Edit Song"

      assert_patch(index_live, Routes.song_index_path(conn, :edit, song))

      assert index_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#song-form", song: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.song_index_path(conn, :index))

      assert html =~ "Song updated successfully"
      assert html =~ "some updated art"
    end

    test "deletes song in listing", %{conn: conn, song: song} do
      {:ok, index_live, _html} = live(conn, Routes.song_index_path(conn, :index))

      assert index_live |> element("#song-#{song.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#song-#{song.id}")
    end
  end

  describe "Show" do
    setup [:create_song]

    test "displays song", %{conn: conn, song: song} do
      {:ok, _show_live, html} = live(conn, Routes.song_show_path(conn, :show, song))

      assert html =~ "Show Song"
      assert html =~ song.art
    end

    test "updates song within modal", %{conn: conn, song: song} do
      {:ok, show_live, _html} = live(conn, Routes.song_show_path(conn, :show, song))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Song"

      assert_patch(show_live, Routes.song_show_path(conn, :edit, song))

      assert show_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#song-form", song: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.song_show_path(conn, :show, song))

      assert html =~ "Song updated successfully"
      assert html =~ "some updated art"
    end
  end
end
