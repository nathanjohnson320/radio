defmodule RadioWeb.ProxyController do
  use RadioWeb, :controller

  alias Plex

  def image(conn, %{"key" => key}) do
    uri = "/#{key |> Enum.join("/")}"
    {:ok, {image, headers}} = Plex.image(uri)

    %{conn | resp_headers: headers ++ conn.resp_headers}
    |> Plug.Conn.send_resp(200, image)
  end
end
