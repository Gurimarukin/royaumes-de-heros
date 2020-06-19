defmodule HerosWeb.UserController do
  use HerosWeb, :controller

  def rename(conn, %{"_json" => name}) do
    case validate_name(name) do
      {:ok, name} ->
        user = conn.assigns.user
        user = put_in(user.name, name)

        conn
        |> assign(:user, user)
        |> put_session(:user, user)
        |> send_resp(200, name)

      :error ->
        send_resp(conn, 400, "")
    end
  end

  defp validate_name(name) do
    name = String.trim(name)

    if String.length(name) > 0 do
      {:ok, name}
    else
      :error
    end
  end
end
