defmodule HerosWeb.Session do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    session_id = get_session(conn, :session_id) || UUID.uuid1(:hex)
    assign(conn, :session_id, session_id)
  end
end
