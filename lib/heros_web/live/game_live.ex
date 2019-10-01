defmodule HerosWeb.GameLive do
  use Phoenix.LiveView

  def mount(session, socket) do
    case Heros.Games.lookup(Heros.Games, session.game_id) do
      {:ok, game_pid} ->
        if connected?(socket) do
          game = Heros.Game.subscribe(game_pid, session.session_id, {self(), update_callback()})

          socket =
            assign(
              socket,
              session_id: session.session_id,
              game_pid: game_pid,
              game: game,
              editable_name: false
            )

          {:ok, socket}
        else
          {:ok, assign(socket, game: :loading)}
        end

      _ ->
        {:ok, assign(socket, game: {:error, :not_found})}
    end
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
    case assigns.game.stage do
      :lobby ->
        HerosWeb.GameView.render("lobby_admin.html", assigns)
    end
  end

  defp update_callback do
    game_view = self()
    fn game -> send(game_view, {:update, game}) end
  end

  def handle_info({:update, game}, socket) do
    {:noreply, assign(socket, game: {:ok, game})}
  end

  def handle_event("editable_name_true", _params, socket) do
    {:noreply, assign(socket, editable_name: true)}
  end

  def handle_event("submit_name", %{"value" => name}, socket) do
    Heros.Game.rename(socket.assigns.game_pid, name)
    {:noreply, assign(socket, editable_name: false)}
  end

  def handle_event("submit_name_key", %{"key" => "Enter", "value" => name}, socket) do
    handle_event("submit_name", %{"value" => name}, socket)
  end

  def handle_event("submit_name_key", %{"key" => "Escape"}, socket) do
    {:noreply, assign(socket, editable_name: false)}
  end

  def handle_event("submit_name_key", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("leave", _path, socket) do
    terminate(:normal, socket)
    {:noreply, redirect(socket, to: HerosWeb.Router.Helpers.page_path(socket, :index))}
  end

  def terminate(_reason, socket) do
    game_pid = Map.get(socket.assigns, :game_pid)
    session_id = Map.get(socket.assigns, :session_id)

    game_pid && Process.alive?(game_pid) && session_id &&
      Heros.Game.unsubscribe(game_pid, session_id, self())
  end
end
