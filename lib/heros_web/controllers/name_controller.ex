defmodule HerosWeb.NameController do
  use HerosWeb, :controller

  def rename(conn, %{"name" => name}) do
    case HerosWeb.HeaderLive.validate_name(name) do
      {:ok, name} ->
        conn =
          fetch_session(conn)
          |> put_session(:user_name, name)

        Heros.Games.user_rename(Heros.Games, get_session(conn, :id), name)

        resp(conn, 200, "")

      :error ->
        resp(conn, 403, "Invalid name")
    end
  end
end
