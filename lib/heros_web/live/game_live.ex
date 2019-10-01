defmodule HerosWeb.GameLive do
  use Phoenix.LiveView

  alias Heros.{Game, Games}
  alias HerosWeb.GameLive

  defp module_for_current_stage(game) do
    case game.stage do
      :lobby -> GameLive.LobbyAdmin
    end
  end

  def mount(session, socket) do
    case Games.lookup(Games, session.game_id) do
      {:ok, game_pid} ->
        if connected?(socket) do
          game = Game.subscribe(game_pid, session.session_id, self())

          socket =
            assign(
              socket,
              [
                session_id: session.session_id,
                game_pid: game_pid,
                game: game
              ] ++ default_assigns()
            )

          {:ok, socket}
        else
          {:ok, assign(socket, game: :loading)}
        end

      _ ->
        {:ok, assign(socket, game: {:error, :not_found})}
    end
  end

  defp default_assigns do
    GameLive.LobbyAdmin.default_assigns()
  end

  def render(assigns) do
    case assigns.game do
      {:ok, game} ->
        render_stage(%{assigns | game: game})

      :loading ->
        ~L"""
        <div>chargement...</div>
        """

      {:error, error} ->
        error =
          case error do
            :not_found -> "Impossible de trouver la partie."
            :game_started -> "Impossible de rejoindre une partie commencée."
            :lobby_full -> "Impossible de rejoindre, le salon est plein."
            _ -> ""
          end

        HerosWeb.GameView.render("error.html", Map.put(assigns, :error, error))
    end
  end

  defp render_stage(assigns) do
    module_for_current_stage(assigns.game).render(assigns)
  end

  def handle_info({:update, game}, socket) do
    {:noreply, assign(socket, game: {:ok, game})}
  end

  def handle_info(:leave, socket) do
    redirect_home(socket)
  end

  # def handle_info(info, socket) do
  #   module_for_current_stage(assigns.game).handle_info(info, socket)
  # end

  def handle_event("leave", _path, socket) do
    with_game(socket, fn game_pid, session_id ->
      Game.leave(game_pid, session_id)
    end)

    redirect_home(socket)
  end

  def handle_event(event, path, socket) do
    module_for_current_stage(socket.assigns.game).handle_event(event, path, socket)
  end

  def terminate(_reason, socket) do
    with_game(socket, fn game_pid, session_id ->
      Game.unsubscribe(game_pid, session_id, self())
    end)
  end

  defp with_game(socket, f) do
    game_pid = Map.get(socket.assigns, :game_pid)
    session_id = Map.get(socket.assigns, :session_id)
    game_pid && Process.alive?(game_pid) && session_id && f.(game_pid, session_id)
  end

  defp redirect_home(socket) do
    {:noreply, redirect(socket, to: HerosWeb.Router.Helpers.games_path(socket, :index))}
  end
end
