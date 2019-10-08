defmodule HerosWeb.GameLive.Lobby do
  def render(assigns) do
    HerosWeb.GameView.render("lobby.html", assigns)
  end

  def default_assigns do
    []
  end
end
