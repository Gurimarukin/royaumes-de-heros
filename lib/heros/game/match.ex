defmodule Heros.Game.Match do
  defstruct players: [],
            current_player: nil

  alias Heros.Game.{Match, Player, Stage}
  alias Heros.Cards

  @behaviour Stage

  def start_game(game) do
    slef = self()

    Task.start(fn ->
      Process.sleep(1000)
      GenServer.call(slef, {:update, :players_draw})
    end)

    put_in(game.match, %Match{})
    |> init_players()
    |> set_current_player()
    |> set_started()
  end

  defp init_players(game) do
    players =
      game.users
      |> Enum.map(fn {session_id, _session} ->
        {session_id, init_player()}
      end)

    put_in(game.match.players, players)
  end

  defp init_player do
    %Player{deck: Cards.Decks.Base.shuffled()}
  end

  defp set_current_player(game) do
    put_in(game.match.current_player, List.first(Map.keys(game.users)))
  end

  defp set_started(game), do: put_in(game.stage, :started)

  def sorted_players(players, player_id), do: sorted_players(players, player_id, {nil, []})

  defp sorted_players([], _player_id, acc), do: acc

  defp sorted_players([{player_id, current_player} | tail], player_id, {_current_player, acc}) do
    {{player_id, current_player}, tail ++ acc}
  end

  defp sorted_players([player | tail], player_id, {current_player, acc}) do
    sorted_players(tail, player_id, {current_player, acc ++ [player]})
  end

  @impl Stage
  def handle_call(_request, _from, _game),
    do: raise(MatchError, message: "no match of handle_call/3")

  @impl Stage
  def projection_for_session(_session_id, game) do
    game
  end

  @impl Stage
  def handle_update(:players_draw, _from, game) do
    {:reply, :ok, players_draw(game)}
  end

  @impl Stage
  def on_update(response), do: response

  defp players_draw(game) do
    case sorted_players(game.match.players, game.match.current_player) do
      {{id_first, _}, others} ->
        game = player_draw(game, id_first, 3)

        case others do
          [{id_other, _}] ->
            player_draw(game, id_other, 5)

          [{id_second, _} | others] ->
            game = player_draw(game, id_second, 4)
            Enum.reduce(others, game, fn {id, _}, game -> player_draw(game, id, 5) end)
        end
    end
  end

  defp player_draw(game, player_id, n) do
    {^player_id, player} = List.keyfind(game.match.players, player_id, 0)

    update_in(
      game.match.players,
      &List.keyreplace(&1, player_id, 0, {player_id, player_draw(player, n)})
    )
  end

  defp player_draw(player, 0), do: player

  defp player_draw(player, n) do
    if length(player.deck) == 0 do
      put_in(player.deck, Enum.shuffle(player.discard))
      |> put_in([:discard], [])
      |> player_draw(n)
    else
      [head | tail] = player.deck

      update_in(player.hand, &(&1 ++ [head]))
      |> put_in([:deck], tail)
      |> player_draw(n - 1)
    end
  end
end
