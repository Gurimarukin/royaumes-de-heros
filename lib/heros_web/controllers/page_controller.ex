defmodule HerosWeb.PageController do
  use HerosWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, HerosWeb.GamesView, session: %{})
  end
end
