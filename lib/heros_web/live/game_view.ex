defmodule HerosWeb.GameView do
  use Phoenix.LiveView

  def render(assigns) do
    HerosWeb.PageView.render("game.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, socket}
  end

  def terminate(_reason, _socket) do
    # IO.inspect(reason, label: "reason")
    # IO.inspect(socket, label: "socket")

    :toto
  end
end
