defmodule HerosWeb.GamesLive do
  use Phoenix.LiveView

  def mount(session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :update)

    {:ok,
     socket
     |> assign(session: session)
     |> get_games()}
  end

  def render(assigns) do
    HerosWeb.GamesView.render("index.html", assigns)
  end

  def handle_info(:update, socket) do
    {:noreply, get_games(socket)}
  end

  def handle_event("create_game", _path, socket) do
    name = ~s"Partie de #{socket.assigns.session.user_name}"
    id = Heros.Games.create(Heros.Games, name)
    {:noreply, redirect(socket, to: HerosWeb.Router.Helpers.game_path(socket, :show, id))}
  end

  defp get_games(socket) do
    assign(socket, games: Heros.Games.list_joinable(Heros.Games))
  end
end
