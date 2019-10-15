defmodule Heros.Game.Match do
  defstruct players: [],
            current_player: nil,
            gems: [],
            market: [],
            market_deck: [],
            sacrifice: []

  alias Heros.Game.{Match, Player, Stage}
  alias Heros.{Cards, Utils}
  alias Heros.Cards.Card

  @behaviour Stage

  def start_game(game) do
    Utils.update_self_after(1000, :players_draw)

    put_in(game.match, %Match{})
    |> init_players()
    |> set_current_player(List.first(Map.keys(game.users)))
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

  defp set_current_player(game, player_id) do
    put_in(game.match.current_player, player_id)
  end

  defp set_started(game), do: put_in(game.stage, :started)

  def play_card(game, id_player, id_card) do
    GenServer.call(game, {:update, {:play_card, id_player, id_card}})
  end

  def end_turn(game, id_player) do
    GenServer.call(game, {:update, {:end_turn, id_player}})
  end

  def sorted_players(players, player_id), do: sorted_players(players, player_id, {nil, []})

  defp sorted_players([], _player_id, acc), do: acc

  defp sorted_players([{player_id, current_player} | tail], player_id, {_current_player, acc}) do
    {{player_id, current_player}, tail ++ acc}
  end

  defp sorted_players([player | tail], player_id, {current_player, acc}) do
    sorted_players(tail, player_id, {current_player, acc ++ [player]})
  end

  defp next_player(players, id_player) do
    case sorted_players(players, id_player) do
      {_, others} ->
        Enum.filter(others, fn {_id, player} -> is_alive(player) end)
        |> List.first()
        |> elem(0)
    end
  end

  def is_current_player(match, id_player), do: match.current_player == id_player

  defp is_alive(player), do: player.hp > 0

  # defp is_alive(players, id_player) do
  #   {_id, player} = List.keyfind(players, id_player, 0)
  #   is_alive(player)
  # end

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

  def handle_update({:player_draw, id_player, n}, _from, game) do
    {:reply, :ok, player_draw(game, id_player, n)}
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

  def handle_update({:end_turn, id_player}, _from, game) do
    if is_current_player(game.match, id_player) do
      game =
        clear_cards(game, id_player)
        |> set_current_player(next_player(game.match.players, id_player))

      Utils.update_self_after(1000, {:player_draw, id_player, 5})

      {:reply, :ok, game}
    else
      {:reply, {:error, :forbidden}, game}
    end
  end

  @impl Stage
  def on_update(response), do: response

  defp update_player(game, player_id, f) do
    update_in(
      game.match.players,
      &Utils.keyupdate(&1, player_id, fn player -> f.(player) end)
    )
  end

  defp player_draw(game, id_player, n) do
    update_player(game, id_player, &player_draw_rec(&1, id_player, n))
  end

  defp player_draw_rec(player, _id_player, 0), do: player

  defp player_draw_rec(player, id_player, n) do
    if length(player.cards.deck) == 0 do
      if length(player.cards.discard) == 0 do
        player
      else
        player =
          put_in(player.cards.deck, Enum.shuffle(player.cards.discard))
          |> put_in([:cards, :discard], [])

        Utils.update_self_after(1000, {:player_draw, id_player, n})

        player
      end
    else
      [head | tail] = player.cards.deck

      update_in(player.cards.hand, &(&1 ++ [head]))
      |> put_in([:cards, :deck], tail)
      |> player_draw_rec(id_player, n - 1)
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
    game =
      update_player(game, id_player, fn player ->
        update_in(player.cards.hand, &Enum.filter(&1, fn c -> c != card end))
        |> update_in([:cards, :fight_zone], &(&1 ++ [card]))
      end)
      |> Card.primary_effect(elem(card, 1))

    {:reply, :ok, game}
  end

  defp play_card(game, _id_player, _zone, _card), do: {:reply, {:error, :forbidden}, game}

  defp clear_cards(game, id_player) do
    update_player(game, id_player, fn player ->
      clear_fight_zone(player)
      # clear_hand
      |> update_in([:cards, :discard], &(player.cards.hand ++ &1))
      |> put_in([:cards, :hand], [])
      # clear_resources
      |> put_in([:gold], 0)
      |> put_in([:attack], 0)
    end)
  end

  defp clear_fight_zone(player) do
    partition =
      Enum.group_by(player.cards.fight_zone, fn {_id, card} -> Card.stays_on_board(card) end)

    fight_zone = partition[true] || []
    discard = partition[false] || []

    put_in(player.cards.fight_zone, fight_zone)
    |> update_in([:cards, :discard], &(discard ++ &1))
  end
end
