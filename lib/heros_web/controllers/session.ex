defmodule HerosWeb.Session do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    id = get_session(conn, :id) || UUID.uuid1(:hex)

    user_name =
      get_session(conn, :user_name) ||
        Enum.random([
          "Varrick",
          "Kraka",
          "Ralyah",
          "Kristov",
          "Arkus",
          "Lys",
          "Shalyah",
          "Borg",
          "Parov"
        ]) <> " (" <> String.slice(id, 0, 5) <> ")"

    conn
    |> assign(:id, id)
    |> assign(:user_name, user_name)
    |> put_session(:id, id)
    |> put_session(:user_name, user_name)
  end
end
