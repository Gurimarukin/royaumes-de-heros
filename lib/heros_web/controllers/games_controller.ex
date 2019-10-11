defmodule HerosWeb.GamesController do
  use HerosWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, HerosWeb.GamesLive, session: conn.assigns)
  end
end
