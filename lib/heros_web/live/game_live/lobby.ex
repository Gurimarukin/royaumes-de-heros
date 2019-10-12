defmodule HerosWeb.GameLive.Lobby do
  alias HerosWeb.GameLive.Stage

  @behaviour Stage

  @impl Stage
  def render(assigns) do
    HerosWeb.GameView.render("lobby.html", assigns)
  end

  @impl Stage
  def default_assigns, do: []

  @impl Stage
  def handle_event(_event, _params, _socket),
    do: raise(MatchError, message: "no match of handle_event/3")

  @impl Stage
  def handle_info(_msg, _socket), do: raise(MatchError, message: "no match of handle_info/2")
end
