defmodule HerosWeb.GameLive.Match do
  import Phoenix.LiveView

  alias Heros.{Game, Games}

  def render(assigns) do
    HerosWeb.GameView.render("match.html", assigns)
  end

  def default_assigns do
    []
  end
end
