defmodule HerosWeb.NameController do
  use HerosWeb, :controller

  def rename(conn, %{"name" => name}) do
    case HerosWeb.HeaderLive.validate_name(name) do
      {:ok, name} ->
        fetch_session(conn)
        |> put_session(:user_name, name)
        |> resp(200, "")

      :error ->
        resp(conn, 403, "Invalid name")
    end
  end
end
