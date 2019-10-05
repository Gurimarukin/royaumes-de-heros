defmodule Heros.Game do
  use GenServer, restart: :temporary

  alias Heros.Game

  defstruct subscribed_sessions: %{},
            stage: :lobby,
            lobby: %Game.Lobby{},
            match: nil

  defp module_for_current_stage(stage) do
    case stage do
      :lobby -> Game.Lobby
      :started -> Game.Match
    end
  end

  defp project(session_id, game) do
    module_for_current_stage(game.stage).projection_for_session(session_id, game)
  end

  def stage_label(stage) do
    case stage do
      :lobby -> "salon"
      :started -> "en jeu"
    end
  end

  #  Client
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def short(game) do
    GenServer.call(game, :short)
  end

  def subscribe(game, session_id, pid) do
    GenServer.call(game, {:update, {:subscribe, session_id, pid}})
  end

  def unsubscribe(game, session_id, pid) do
    GenServer.call(game, {:update, {:unsubscribe, session_id, pid}})
  end

  def leave(game, session_id) do
    GenServer.call(game, {:update, {:leave, session_id}})
  end

  # Server
  def init(:ok) do
    {:ok, %Game{}}
  end

  def handle_call(:short, _from, game) do
    {:reply,
     %{
       is_public: game.lobby.is_public,
       n_players: map_size(game.subscribed_sessions),
       max_players: game.lobby.max_players,
       stage: game.stage,
       name: game.lobby.name
     }, game}
  end

  def handle_call({:update, update}, from, game) do
    case handle_update(update, from, game) do
      {:reply, reply, new_game} ->
        {:reply, reply, maybe_changed(new_game, game)}

      # {:reply, reply, new_game, timeout} -> {:reply, reply, maybe_changed(new_game, game), timeout}
      # {:noreply, new_game} -> {:noreply, maybe_changed(new_game, game)}
      # {:noreply, new_game, timeout} -> {:noreply, maybe_changed(new_game, game), timeout}

      {:stop, reason, reply, new_game} ->
        {:stop, reason, reply, maybe_changed(new_game, game)}

        # {:stop, reason, new_game} -> {:stop, reason, maybe_changed(new_game, game)}
    end
  end

  def handle_call(request, from, game) do
    module_for_current_stage(game.stage).handle_call(request, from, game)
  end

  defp maybe_changed(new_game, game) do
    if new_game != game do
      new_game
      |> module_for_current_stage(game.stage).on_update()
      |> broadcast_update()
    else
      new_game
    end
  end

  defp broadcast_update(game) do
    game.subscribed_sessions
    |> Enum.map(fn {session_id, subscriptions} ->
      projection = project(session_id, game)
      subscriptions |> Enum.map(fn pid -> send(pid, {:update, projection}) end)
    end)

    game
  end

  def handle_update({:subscribe, session_id, pid}, _from, game) do
    case game.subscribed_sessions[session_id] do
      nil -> subscribe_new_session(game, session_id, pid)
      _ -> subscribe_existing_session(game, session_id, pid)
    end
  end

  def handle_update({:unsubscribe, session_id, pid}, _from, game) do
    case game.subscribed_sessions[session_id] do
      nil -> {:reply, :ok, game}
      subscriptions -> unsubscribe_session(game, session_id, subscriptions, pid)
    end
  end

  def handle_update({:leave, session_id}, _from, game) do
    case game.subscribed_sessions[session_id] do
      nil -> {:reply, :ok, game}
      subscriptions -> player_leave(game, session_id, subscriptions)
    end
  end

  def handle_update(update, from, game) do
    module_for_current_stage(game.stage).handle_update(update, from, game)
  end

  defp subscribe_new_session(game, session_id, pid) do
    if game.stage == :lobby do
      subscribe_lobby(game, session_id, pid)
    else
      {:reply, {:error, :game_started}, game}
    end
  end

  defp subscribe_lobby(game, session_id, pid) do
    n_players = map_size(game.subscribed_sessions)

    if n_players < game.lobby.max_players do
      game = put_in(game.subscribed_sessions[session_id], MapSet.new([pid]))
      {:reply, {:ok, project(session_id, game)}, game}
    else
      {:reply, {:error, :lobby_full}, game}
    end
  end

  defp subscribe_existing_session(game, session_id, pid) do
    game = update_in(game.subscribed_sessions[session_id], &MapSet.put(&1, pid))
    {:reply, {:ok, project(session_id, game)}, game}
  end

  defp unsubscribe_session(game, session_id, subscriptions, pid) do
    subscriptions = MapSet.delete(subscriptions, pid)

    subscribed_sessions =
      if game.stage == :lobby and MapSet.size(subscriptions) == 0 do
        Map.delete(game.subscribed_sessions, session_id)
      else
        Map.put(game.subscribed_sessions, session_id, subscriptions)
      end

    stop_if_no_sessions(%{game | subscribed_sessions: subscribed_sessions})
  end

  defp player_leave(game, session_id, subscriptions) do
    subscriptions |> Enum.map(fn pid -> send(pid, :leave) end)

    stop_if_no_sessions(update_in(game.subscribed_sessions, &Map.delete(&1, session_id)))
  end

  defp stop_if_no_sessions(game) do
    if map_size(game.subscribed_sessions) == 0 do
      {:stop, :normal, :ok, game}
    else
      {:reply, :ok, game}
    end
  end
end
