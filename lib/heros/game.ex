defmodule Heros.Game do
  use GenServer, restart: :temporary

  alias Heros.{Game, Utils}

  defstruct users: %{},
            stage: :lobby,
            lobby: %Game.Lobby{},
            match: nil

  def module_for_current_stage(stage) do
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

  def subscribe(game, session, pid) do
    GenServer.call(game, {:update, {:subscribe, session, pid}})
  end

  def unsubscribe(game, pid) do
    GenServer.call(game, {:update, {:unsubscribe, pid}})
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
       n_players: map_size(game.users),
       max_players: game.lobby.max_players,
       stage: game.stage,
       name: game.lobby.name
     }, game}
  end

  def handle_call({:update, update}, from, game) do
    response = handle_update(update, from, game)

    Utils.flat_map_call_response(response, fn new_game ->
      if new_game != game do
        module_for_current_stage(game.stage).on_update(response)
        |> Utils.map_call_response(&broadcast_update/1)
      else
        response
      end
    end)
  end

  def handle_call(request, from, game) do
    module_for_current_stage(game.stage).handle_call(request, from, game)
  end

  defp broadcast_update(game) do
    Enum.map(game.users, fn {id, user} ->
      projection = project(id, game)
      Enum.map(user.connected_views, fn pid -> send(pid, {:update, projection}) end)
    end)

    game
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, game) do
    case handle_call({:update, {:unsubscribe, pid}}, nil, game) do
      {:stop, reason, _reply, game} -> {:stop, reason, game}
      {:reply, _reply, game} -> {:noreply, game}
    end
  end

  def handle_update({:subscribe, session, pid}, _from, game) do
    case game.users[session.id] do
      nil -> subscribe_new_session(game, session, pid)
      _ -> subscribe_existing_session(game, session.id, pid)
    end
  end

  def handle_update({:unsubscribe, pid}, _from, game) do
    users =
      Enum.reduce(game.users, game.users, fn {id, user}, users ->
        user = update_in(user.connected_views, &MapSet.delete(&1, pid))

        if MapSet.size(user.connected_views) == 0 and game.stage == :lobby do
          Map.delete(users, id)
        else
          Map.put(users, id, user)
        end
      end)

    stop_if_no_users(put_in(game.users, users))
  end

  def handle_update({:leave, session_id}, _from, game) do
    case game.users[session_id] do
      nil -> {:reply, :ok, game}
      user -> player_leave(game, session_id, user)
    end
  end

  def handle_update(update, from, game) do
    module_for_current_stage(game.stage).handle_update(update, from, game)
  end

  defp subscribe_new_session(game, session, pid) do
    if game.stage == :lobby do
      subscribe_lobby(game, session, pid)
    else
      {:reply, {:error, :game_started}, game}
    end
  end

  defp subscribe_lobby(game, session, pid) do
    n_players = map_size(game.users)

    if n_players < game.lobby.max_players do
      game =
        put_in(game.users[session.id], %Game.User{
          connected_views: MapSet.new([pid]),
          user_name: session.user_name
        })

      with_pid_monitored(game, session.id, pid)
    else
      {:reply, {:error, :lobby_full}, game}
    end
  end

  defp subscribe_existing_session(game, session_id, pid) do
    game =
      update_in(
        game.users[session_id],
        fn session -> update_in(session.connected_views, &MapSet.put(&1, pid)) end
      )

    with_pid_monitored(game, session_id, pid)
  end

  defp with_pid_monitored(game, session_id, pid) do
    Process.monitor(pid)
    {:reply, {:ok, project(session_id, game)}, game}
  end

  defp player_leave(game, session_id, session) do
    session.connected_views |> Enum.map(fn pid -> send(pid, :leave) end)

    stop_if_no_users(update_in(game.users, &Map.delete(&1, session_id)))
  end

  defp stop_if_no_users(game) do
    if map_size(game.users) == 0 do
      {:stop, :normal, :ok, game}
    else
      {:reply, :ok, game}
    end
  end
end
