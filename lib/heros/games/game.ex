defmodule Heros.Game do
  use GenServer, restart: :temporary

  alias Heros.{Game, Player}

  defstruct public: true,
            players: %{},
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
      n_players: map_size(game.players),
      max_players: game.max_players,
      stage: game.stage,
      name: game.name
    }
  end

  def rename(game, name) do
    GenServer.call(game, {:update, {:rename, name}})
  end

  def subscribe(game, player_id, {id, callback}) do
    GenServer.call(game, {:update, {:subscribe, player_id, {id, callback}}})
  end

  def unsubscribe(game, player_id, callback_id) do
    GenServer.call(game, {:update, {:unsubscribe, player_id, callback_id}})
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
      player.subscribed |> Enum.map(fn {_id, callback} -> callback.(game) end)
    end)
  end

  defp handle_update({:rename, name}, _from, game) do
    {:reply, :ok, %{game | name: name}}
  end

  defp handle_update({:subscribe, player_id, {id, callback}}, _from, game) do
    if game.stage == :lobby do
      subscribe_lobby(game, player_id, {id, callback})
    else
      {:reply, {:error, :game_started}, game}
    end
  end

  defp handle_update({:unsubscribe, player_id, callback_id}, _from, game) do
    case Map.get(game.players, player_id) do
      nil ->
        {:reply, :ok, game}

      player ->
        player = %{player | subscribed: Map.delete(player.subscribed, callback_id)}

        players =
          if game.stage == :lobby and map_size(player.subscribed) == 0 do
            Map.delete(game.players, player_id)
          else
            game.players
          end

        game = %{game | players: players}

        if map_size(players) == 0 do
          {:stop, :normal, :ok, game}
        else
          {:reply, :ok, game}
        end
    end
  end

  defp subscribe_lobby(game, player_id, {id, callback}) do
    n_players = map_size(game.players)

    if n_players < game.max_players do
      player =
        Map.get(
          game.players,
          player_id,
          if(n_players == 0, do: %Player{is_owner: true}, else: %Player{})
        )

      player = %{player | subscribed: Map.put(player.subscribed, id, callback)}

      {:reply, {:ok, game}, %{game | players: Map.put(game.players, player_id, player)}}
    else
      {:reply, {:error, :lobby_full}, game}
    end
  end
end
