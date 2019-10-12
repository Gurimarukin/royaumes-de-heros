defmodule HerosWeb.GameLive.LobbyAdmin do
  import Phoenix.LiveView

  alias Heros.Game
  alias HerosWeb.GameLive.Stage

  @behaviour Stage

  @impl Stage
  def render(assigns) do
    HerosWeb.GameView.render("lobby_admin.html", assigns)
  end

  @impl Stage
  def default_assigns, do: [edit_name: false]

  @impl Stage
  def handle_event("edit_name", _params, socket) do
    {:noreply, assign(socket, edit_name: true)}
  end

  def handle_event("submit_name", %{"value" => name}, socket) do
    Game.Lobby.rename(socket.assigns.game_pid, name)
    {:noreply, assign(socket, edit_name: false)}
  end

  def handle_event("keyup_name", %{"key" => "Enter", "value" => name}, socket) do
    handle_event("submit_name", %{"value" => name}, socket)
  end

  def handle_event("keyup_name", %{"key" => "Escape"}, socket) do
    {:noreply, assign(socket, edit_name: false)}
  end

  def handle_event("keyup_name", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("toggle_public", _params, socket) do
    Game.Lobby.toggle_public(socket.assigns.game_pid)
    {:noreply, socket}
  end

  def handle_event("kick", %{"id" => id}, socket) do
    Game.leave(socket.assigns.game_pid, id)
    {:noreply, socket}
  end

  def handle_event("start", _params, socket) do
    Game.Lobby.start(socket.assigns.game_pid)
    {:noreply, socket}
  end

  @impl Stage
  def handle_info(_msg, _socket), do: raise(MatchError, message: "no match of handle_info/2")
end
