defmodule HerosWeb.GameLive.Lobby do
  import Phoenix.LiveView

  alias Heros.{Game, Games}

  def render(assigns) do
    HerosWeb.GameView.render("lobby.html", assigns)
  end

  def default_assigns do
    []
  end
end
