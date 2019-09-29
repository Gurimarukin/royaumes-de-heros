defmodule HerosWeb.GamesView do
  use Phoenix.LiveView

  def render(assigns) do
    HerosWeb.PageView.render("games.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :update)

    {:ok, get_games(socket)}
  end

  def handle_info(:update, socket) do
    {:noreply, get_games(socket)}
  end

  def handle_event("create_game", _path, socket) do
    id = Heros.Games.create(Heros.Games)

    {:noreply, redirect(socket, to: HerosWeb.Router.Helpers.game_path(socket, :show, id))}
  end

  defp get_games(socket) do
    games = Heros.Games.list(Heros.Games)

    assign(socket,
      games:
        games
        |> Enum.filter(fn game ->
          game.public and game.stage == :lobby
        end)
    )
  end
end
