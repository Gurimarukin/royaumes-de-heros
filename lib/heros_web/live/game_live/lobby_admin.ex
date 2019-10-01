defmodule HerosWeb.GameLive.LobbyAdmin do
  import Phoenix.LiveView

  alias Heros.{Game, Games}

  def render(assigns) do
    HerosWeb.GameView.render("lobby_admin.html", assigns)
  end

  def default_assigns do
    [edit_name: false]
  end

  def handle_event("edit_name", _params, socket) do
    {:noreply, assign(socket, assign(socket, edit_name: true))}
  end

  def handle_event("submit_name", %{"value" => name}, socket) do
    Game.Lobby.rename(socket.assigns.game_pid, name)
    {:noreply, assign(socket, assign(socket, edit_name: false))}
  end

  def handle_event("keyup_name", %{"key" => "Enter", "value" => name}, socket) do
    handle_event("submit_name", %{"value" => name}, socket)
  end

  def handle_event("keyup_name", %{"key" => "Escape"}, socket) do
    {:noreply, assign(socket, assign(socket, edit_name: false))}
  end

  def handle_event("keyup_name", _params, socket) do
    {:noreply, socket}
  end
end
