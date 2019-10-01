defmodule Heros.Game do
  use GenServer, restart: :temporary

  alias Heros.{Game, Player}

  defstruct public: true,
            players: [],
            max_players: 4,
            stage: :lobby,
            name: "Nouvelle partie"

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
      public: game.public,
      n_players: length(game.players),
      max_players: game.max_players,
      stage: game.stage,
      name: game.name
    }
  end

  def rename(game, name) do
    GenServer.call(game, {:update, {:rename, name}})
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
    {res, game} =
      case handle_update(update, from, game) do
        {:reply, reply, game} ->
          {{:reply, reply, game}, game}

        # {:reply, reply, game, timeout} -> {{:reply, reply, game, timeout}, game}
        # {:noreply, game} -> {{:noreply, game}, game}
        # {:noreply, game, timeout} -> {{:noreply, game, timeout}, game}
        {:stop, reason, reply, game} ->
          {{:stop, reason, reply, game}, game}
          # {:stop, reason, game} -> {{:stop, reason, game}, game}
      end

    broadcast_update(game)
    res
  end

  defp broadcast_update(game) do
    game.players
    |> Enum.map(fn {_id, player} ->
      player.subscribed |> Enum.map(fn pid -> send(pid, {:update, game}) end)
    end)
  end

  defp handle_update({:rename, name}, _from, game) do
    {:reply, :ok, %{game | name: name}}
  end

  defp handle_update({:subscribe, player_id, pid}, _from, game) do
    if game.stage == :lobby do
      subscribe_lobby(game, player_id, pid)
    else
      {:reply, {:error, :game_started}, game}
    end
  end

  defp handle_update({:unsubscribe, player_id, pid}, _from, game) do
    case List.keyfind(game.players, player_id, 0) do
      nil -> {:reply, :ok, game}
      player -> unsubscribe_player(game, player, pid)
    end
  end

  defp handle_update({:leave, player_id}, _from, game) do
    case List.keyfind(game.players, player_id, 0) do
      nil -> {:reply, :ok, game}
      player -> player_leave(game, player)
    end
  end

  defp subscribe_lobby(game, player_id, pid) do
    n_players = length(game.players)

    if n_players < game.max_players do
      players =
        case List.keyfind(game.players, player_id, 0) do
          nil ->
            player = if n_players == 0, do: %Player{is_owner: true}, else: %Player{}
            player = %{player | subscribed: MapSet.new([pid])}
            game.players ++ [{player_id, player}]

          {_, player} ->
            player = %{player | subscribed: MapSet.put(player.subscribed, pid)}
            List.keyreplace(game.players, player_id, 0, {player_id, player})
        end

      {:reply, {:ok, game}, %{game | players: players}}
    else
      {:reply, {:error, :lobby_full}, game}
    end
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
