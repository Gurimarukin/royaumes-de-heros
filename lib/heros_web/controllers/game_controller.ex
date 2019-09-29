defmodule HerosWeb.GameController do
  use HerosWeb, :controller

  alias Phoenix.LiveView

  def show(conn, %{"id" => id}) do
    LiveView.Controller.live_render(
      conn,
      HerosWeb.GameView,
      session: Map.put(conn.assigns, :game_id, id)
    )
  end
end
