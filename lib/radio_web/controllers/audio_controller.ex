defmodule RadioWeb.AudioController do
  use RadioWeb, :controller

  alias Radio.Broadcasts
  alias RadioWeb.Endpoint

  def index(conn, %{"id" => id}) do
    station = Broadcasts.get_station!(id, [:genres])

    conn =
      conn
      |> put_resp_content_type("audio/mpeg")
      |> put_resp_header("icy-br", "320")
      |> put_resp_header("icy-genre", Enum.map(station.genres, & &1.name) |> Enum.join(","))
      |> put_resp_header("icy-name", station.name)
      |> put_resp_header(
        "icy-notice1",
        "<BR>This stream requires <a href=\"http://www.winamp.com\">Winamp</a><BR>"
      )
      |> put_resp_header("icy-notice2", "Shoutcast DNAS/posix(linux x64) v2.6.0.753<BR>")
      |> put_resp_header("icy-pub", "1")
      |> put_resp_header("icy-sr", "44000")
      |> send_icy()
      |> put_resp_header("icy-url", "https://www.example.com")
      |> send_chunked(200)

    :ok = Endpoint.subscribe(to_string(station.id))
    send_chunk_to_connection(conn, id)
  end

  defp send_chunk_to_connection(conn, id) do
    receive do
      %Phoenix.Socket.Broadcast{
        event: "input",
        payload: %{
          data: buffer
        },
        topic: id
      } ->
        case chunk(conn, buffer) do
          {:ok, conn} ->
            send_chunk_to_connection(conn, id)

          {:error, _err} ->
            send_chunk_to_connection(conn, id)
        end

      _data ->
        send_chunk_to_connection(conn, id)
    end
  end

  defp send_icy(conn) do
    case get_req_header(conn, "icy-metadata") do
      [] ->
        conn

      ["1"] ->
        # TODO: figure out ice metadata and chunking audio
        # put_resp_header(conn, "icy-metaint", "8192")
        conn
    end
  end
end
