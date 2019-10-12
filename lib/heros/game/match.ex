defmodule Heros.Game.Match do
  defstruct players: [],
            current_player: nil

  alias Heros.Game.{Match, Player, Stage}
  alias Heros.Cards
  alias Heros.Cards.Card

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
    put_in(%Player{}.cards.deck, Cards.Decks.Base.shuffled())
  end

  defp set_current_player(game) do
    put_in(game.match.current_player, List.first(Map.keys(game.users)))
  end

  defp set_started(game), do: put_in(game.stage, :started)

  def play_card(game, id_player, id_card) do
    GenServer.call(game, {:update, {:play_card, id_player, id_card}})
  end

  def sorted_players(players, player_id), do: sorted_players(players, player_id, {nil, []})

  defp sorted_players([], _player_id, acc), do: acc

  defp sorted_players([{player_id, current_player} | tail], player_id, {_current_player, acc}) do
    {{player_id, current_player}, tail ++ acc}
  end

  defp sorted_players([player | tail], player_id, {current_player, acc}) do
    sorted_players(tail, player_id, {current_player, acc ++ [player]})
  end

  def is_current_player(match, id_player), do: match.current_player == id_player

  @impl Stage
  def handle_call(_request, _from, _game),
    do: raise(MatchError, message: "no match of handle_call/3")

  @impl Stage
  def projection_for_session(_session_id, game) do
    game
  end

  @impl Stage
  def handle_update(:players_draw, _from, game) do
    game =
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

    {:reply, :ok, game}
  end

  def handle_update({:play_card, id_player, id_card}, _from, game) do
    if is_current_player(game.match, id_player) do
      case find_card(game.match.players, id_card) do
        nil ->
          {:reply, {:error, :not_found}, game}

        {player_id, zone, card} ->
          if player_id == id_player do
            play_card(game, id_player, zone, card)
          else
            {:reply, {:error, :forbidden}, game}
          end
      end
    else
      {:reply, {:error, :forbidden}, game}
    end
  end

  @impl Stage
  def on_update(response), do: response

  defp player_draw(game, player_id, n) do
    {^player_id, player} = List.keyfind(game.match.players, player_id, 0)

    update_in(
      game.match.players,
      &List.keyreplace(&1, player_id, 0, {player_id, player_draw(player, n)})
    )
  end

  defp player_draw(player, 0), do: player

  defp player_draw(player, n) do
    if length(player.cards.deck) == 0 do
      put_in(player.cards.deck, Enum.shuffle(player.cards.discard))
      |> put_in([:cards, :discard], [])
      |> player_draw(n)
    else
      [head | tail] = player.cards.deck

      update_in(player.cards.hand, &(&1 ++ [head]))
      |> put_in([:cards, :deck], tail)
      |> player_draw(n - 1)
    end
  end

  defp find_card(players, id) do
    Enum.find_value(players, fn {id_player, player} ->
      Enum.find_value(player.cards, fn {zone, cards} ->
        Enum.find_value(cards, fn {id_card, card} ->
          if id == id_card, do: {id_player, zone, {id_card, card}}, else: nil
        end)
      end)
    end)
  end

  defp play_card(game, id_player, :hand, card) do
    {^id_player, player} = List.keyfind(game.match.players, id_player, 0)

    player =
      player
      |> update_in([:cards, :hand], &Enum.filter(&1, fn c -> c != card end))
      |> update_in([:cards, :fight_zone], &(&1 ++ [card]))

    game =
      update_in(game.match.players, &List.keyreplace(&1, id_player, 0, {id_player, player}))
      |> Card.primary_effect(elem(card, 1))

    {:reply, :ok, game}
  end

  defp play_card(game, _id_player, _zone, _card), do: {:reply, {:error, :forbidden}, game}
end
