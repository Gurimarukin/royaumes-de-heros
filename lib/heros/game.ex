defmodule Heros.Game do
  use GenServer, restart: :temporary

  alias Heros.{Game, Player}

  defstruct is_public: false,
            players: [],
            max_players: 4,
            stage: :lobby,
            name: "Nouvelle partie",
            ready: false

  defp module_for_current_stage(stage) do
    case stage do
      :lobby -> Game.Lobby
      :started -> Game.Match
    end
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

  def get(game) do
    GenServer.call(game, :get)
  end

  def short(game) do
    game = get(game)

    %{
      is_public: game.is_public,
      n_players: length(game.players),
      max_players: game.max_players,
      stage: game.stage,
      name: game.name
    }
  end

  def subscribe(game, player_id, pid) do
    GenServer.call(game, {:update, {:subscribe, player_id, pid}})
  end

  def unsubscribe(game, player_id, pid) do
    GenServer.call(game, {:update, {:unsubscribe, player_id, pid}})
  end

  def leave(game, player_id) do
    GenServer.call(game, {:update, {:leave, player_id}})
  end

  # Server
  def init(:ok) do
    {:ok, %Game{}}
  end

  def handle_call(:get, _from, game) do
    {:reply, game, game}
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
      |> update_state_ready()
      |> broadcast_update()
    else
      new_game
    end
  end

  defp update_state_ready(game) do
    %{game | ready: length(game.players) >= 2}
  end

  defp broadcast_update(game) do
    game.players
    |> Enum.map(fn {_id, player} ->
      player.subscribed |> Enum.map(fn pid -> send(pid, {:update, game}) end)
    end)

    game
  end

  def handle_update({:subscribe, player_id, pid}, _from, game) do
    case List.keyfind(game.players, player_id, 0) do
      nil -> subscribe_new_player(game, player_id, pid)
      player -> subscribe_existing_player(game, player, pid)
    end
  end

  def handle_update({:unsubscribe, player_id, pid}, _from, game) do
    case List.keyfind(game.players, player_id, 0) do
      nil -> {:reply, :ok, game}
      player -> unsubscribe_player(game, player, pid)
    end
  end

  def handle_update({:leave, player_id}, _from, game) do
    case List.keyfind(game.players, player_id, 0) do
      nil -> {:reply, :ok, game}
      player -> player_leave(game, player)
    end
  end

  def handle_update(update, from, game) do
    module_for_current_stage(game.stage).handle_update(update, from, game)
  end

  defp subscribe_new_player(game, player_id, pid) do
    if game.stage == :lobby do
      subscribe_lobby(game, player_id, pid)
    else
      {:reply, {:error, :game_started}, game}
    end
  end

  defp subscribe_lobby(game, player_id, pid) do
    n_players = length(game.players)

    if n_players < game.max_players do
      player = %Player{subscribed: MapSet.new([pid]), is_admin: n_players == 0}
      players = game.players ++ [{player_id, player}]
      {:reply, {:ok, game}, %{game | players: players}}
    else
      {:reply, {:error, :lobby_full}, game}
    end
  end

  defp subscribe_existing_player(game, {player_id, player}, pid) do
    player = %{player | subscribed: MapSet.put(player.subscribed, pid)}
    players = List.keyreplace(game.players, player_id, 0, {player_id, player})
    {:reply, {:ok, game}, %{game | players: players}}
  end

  defp unsubscribe_player(game, {player_id, player}, pid) do
    player = %{player | subscribed: MapSet.delete(player.subscribed, pid)}

    players =
      if game.stage == :lobby and MapSet.size(player.subscribed) == 0 do
        List.keydelete(game.players, player_id, 0)
      else
        List.keyreplace(game.players, player_id, 0, {player_id, player})
      end

    stop_if_no_players(%{game | players: players})
  end

  defp player_leave(game, {player_id, player}) do
    player.subscribed |> Enum.map(fn pid -> send(pid, :leave) end)

    stop_if_no_players(%{game | players: List.keydelete(game.players, player_id, 0)})
  end

  defp stop_if_no_players(game) do
    if length(game.players) == 0 do
      {:stop, :normal, :ok, game}
    else
      {:reply, :ok, game}
    end
  end
end
