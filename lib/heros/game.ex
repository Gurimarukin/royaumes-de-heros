defmodule Heros.Game do
  use GenServer, restart: :temporary

  require Logger

  alias Heros.{Game, Utils}

  defstruct users: [],
            stage: :lobby,
            lobby: %Game.Lobby{},
            match: nil

  @behaviour Access

  @impl Access
  def fetch(game, key), do: Map.fetch(game, key)

  @impl Access
  def get_and_update(game, key, fun), do: Map.get_and_update(game, key, fun)

  @impl Access
  def pop(game, key, default \\ nil), do: Map.pop(game, key, default)

  def module_for_current_stage(stage) do
    case stage do
      :lobby -> Game.Lobby
      :started -> Game.Match
    end
  end

  defp project(session_id, game) do
    module_for_current_stage(game.stage).projection_for_session(session_id, game)
  end

  #  Client
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, [])
  end

  def short(game) do
    GenServer.call(game, :short)
  end

  def subscribe(game, session, pid) do
    GenServer.call(game, {:update, {:subscribe, session, pid}})
  end

  def leave(game, session_id) do
    GenServer.call(game, {:update, {:leave, session_id}})
  end

  def user_rename(game, id_user, new_name) do
    GenServer.call(game, {:update, {:user_rename, id_user, new_name}})
  end

  # Server
  @impl true
  def init(game_name) do
    {:ok, put_in(%Game{}.lobby.name, game_name)}
  end

  @impl true
  def handle_call(:short, _from, game) do
    {:reply,
     %{
       is_public: game.lobby.is_public,
       n_players: length(game.users),
       max_players: game.lobby.max_players,
       stage: game.stage,
       name: game.lobby.name
     }, game}
  end

  def handle_call({:update, update}, from, game) do
    response = handle_update(update, from, game)

    Utils.flat_map_call_response(response, fn new_game ->
      if new_game != game do
        response =
          module_for_current_stage(game.stage).on_update(response)
          |> stop_if_no_users()

        Utils.map_call_response(response, &broadcast_update/1)
        response
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
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, game) do
    case handle_call({:update, {:unsubscribe, pid}}, nil, game) do
      {:stop, reason, _reply, game} -> {:stop, reason, game}
      {:reply, _reply, game} -> {:noreply, game}
    end
  end

  def handle_info(msg, game) do
    module_for_current_stage(game.stage).handle_info(msg, game)
  end

  def handle_update({:subscribe, session, pid}, _from, game) do
    case Utils.keyfind(game.users, session.id) do
      nil -> subscribe_new_session(game, session, pid)
      _ -> subscribe_existing_user(game, session.id, pid)
    end
  end

  def handle_update({:unsubscribe, pid}, _from, game) do
    case Enum.find(game.users, fn {_id, user} -> MapSet.member?(user.connected_views, pid) end) do
      {id, _} ->
        game =
          update_in(game.users, fn users ->
            Utils.keyupdate(users, id, fn user ->
              update_in(user.connected_views, &MapSet.delete(&1, pid))
              |> put_in([:last_seen], System.system_time(:millisecond))
            end)
          end)

        if MapSet.size(Utils.keyfind(game.users, id).connected_views) == 0 do
          Logger.debug(
            ~s"Game #{game.lobby.name}: no more connections for #{
              Utils.keyfind(game.users, id).user_name
            }"
          )

          Utils.update_self_after(10000, {:check_reconnected, id})
        end

        {:reply, :ok, game}

      _ ->
        {:reply, :not_found, game}
    end
  end

  def handle_update({:check_reconnected, id_user}, _from, game) do
    case Utils.keyfind(game.users, id_user) do
      nil ->
        {:reply, :not_found, game}

      user ->
        game =
          if System.system_time(:millisecond) >= user.last_seen + 10000 do
            Logger.debug(~s"Game #{game.lobby.name}: #{user.user_name} disconnected")
            update_in(game.users, &Utils.keydelete(&1, id_user))
          else
            Logger.debug(~s"Game #{game.lobby.name}: #{user.user_name} reconnected in time")
            game
          end

        {:reply, :ok, game}
    end
  end

  def handle_update({:leave, id_user}, _from, game) do
    case Utils.keyfind(game.users, id_user) do
      nil -> {:reply, :ok, game}
      user -> player_leave(game, id_user, user)
    end
  end

  def handle_update({:user_rename, id_user, name}, _from, game) do
    game =
      update_in(game.users, fn users ->
        Utils.keyupdate(users, id_user, fn user -> put_in(user.user_name, name) end)
      end)

    {:reply, :ok, game}
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
    n_players = length(game.users)

    if n_players < game.lobby.max_players do
      game =
        update_in(game.users, fn users ->
          users ++
            [
              {session.id,
               %Game.User{
                 connected_views: MapSet.new([pid]),
                 user_name: session.user_name,
                 last_seen: System.system_time(:millisecond)
               }}
            ]
        end)

      Logger.debug(~s"Game #{game.lobby.name}: #{session.user_name} joined")

      with_pid_monitored(game, session.id, pid)
    else
      {:reply, {:error, :lobby_full}, game}
    end
  end

  defp subscribe_existing_user(game, session_id, pid) do
    game =
      update_in(game.users, fn users ->
        Utils.keyupdate(users, session_id, fn user ->
          update_in(user.connected_views, &MapSet.put(&1, pid))
          |> put_in([:last_seen], System.system_time(:millisecond))
        end)
      end)

    with_pid_monitored(game, session_id, pid)
  end

  defp with_pid_monitored(game, session_id, pid) do
    Process.monitor(pid)
    {:reply, {:ok, project(session_id, game)}, game}
  end

  defp player_leave(game, id_user, user) do
    Enum.map(user.connected_views, fn pid -> send(pid, :leave) end)
    Logger.debug(~s"Game #{game.lobby.name}: #{user.user_name} left")

    stop_if_no_users({:reply, :ok, update_in(game.users, &Utils.keydelete(&1, id_user))})
  end

  defp stop_if_no_users(response) do
    Utils.flat_map_call_response(response, fn game ->
      if length(game.users) == 0 do
        {:stop, :normal, :ok, game}
      else
        response
      end
    end)
  end
end
