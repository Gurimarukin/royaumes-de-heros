defmodule HerosWeb.TestGameController do
  use HerosWeb, :controller

  alias Phoenix.LiveView

  def show(conn, _params) do
    LiveView.Controller.live_render(
      conn,
      HerosWeb.TestGameLive
    )
  end
end
