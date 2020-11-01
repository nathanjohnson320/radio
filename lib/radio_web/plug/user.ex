defmodule RadioWeb.Plug.User do
  @moduledoc ~S"""
  Plug to handle setting a unique ID for the current user
  """
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    uid = Ecto.UUID.generate()

    conn
    |> put_session(:current_user_id, uid)
    |> put_session(:live_socket_id, "users_socket:#{uid}")
  end
end
