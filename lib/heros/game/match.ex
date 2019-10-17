defmodule Heros.Game.Match do
  defstruct players: [],
            current_player: nil,
            gems: [],
            market: [],
            market_deck: [],
            sacrifice: []

  alias Heros.Game.{Match, Player, Stage}
  alias Heros.Utils
  alias Heros.Cards.Card

  @behaviour Access

  @impl Access
  def fetch(match, key), do: Map.fetch(match, key)

  @impl Access
  def get_and_update(match, key, fun), do: Map.get_and_update(match, key, fun)

  @impl Access
  def pop(match, key, default \\ nil), do: Map.pop(match, key, default)

  @behaviour Stage

  def start_game(game) do
    Utils.update_self_after(1000, :players_draw)
    Utils.update_self_after(1000, :refill_market)

    put_in(game.match, %Match{})
    |> init_players()
    |> put_in([:match, :gems], Card.get_gems())
    |> put_in([:match, :market], List.duplicate(nil, 5))
    |> put_in([:match, :market_deck], Card.get_market())
    |> set_current_player(List.first(Map.keys(game.users)))
    |> put_in([:stage], :started)
  end

  defp init_players(game) do
    players =
      game.users
      |> Enum.map(fn {session_id, _session} -> {session_id, Player.init()} end)

    put_in(game.match.players, players)
  end

  defp set_current_player(game, player_id), do: put_in(game.match.current_player, player_id)

  def play_card(game, id_player, id_card) do
    GenServer.call(game, {:update, {:play_card, id_player, id_card}})
  end

  def attack_hero(game, id_attacker, id_defender) do
    GenServer.call(game, {:update, {:attack_hero, id_attacker, id_defender}})
  end

  def end_turn(game, id_player) do
    GenServer.call(game, {:update, {:end_turn, id_player}})
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
  def handle_update(:refill_market, _from, game) do
    match =
      Enum.with_index(game.match.market)
      |> Enum.reduce(game.match, fn {slot, i}, match ->
        case slot do
          nil ->
            [head | tail] = match.market_deck

            update_in(match.market, &List.replace_at(&1, i, head))
            |> put_in([:market_deck], tail)

          _ ->
            match
        end
      end)

    {:reply, :ok, put_in(game.match, match)}
  end

  def handle_update(:players_draw, _from, game) do
    game =
      case Player.sorted(game.match.players, game.match.current_player) do
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
      case find_card(game.match, id_card) do
        nil ->
          {:reply, {:error, :not_found}, game}

        {nil, zone, card} ->
          buy_card(game, id_player, zone, card)

        {^id_player, zone, card} ->
          play_own_card(game, id_player, zone, card)

        _ ->
          {:reply, {:error, :forbidden}, game}
      end
    else
      {:reply, {:error, :forbidden}, game}
    end
  end

  def handle_update({:attack_hero, id_attacker, id_defender}, _from, game) do
    defender = Utils.keyfind(game.match.players, id_defender)

    if id_attacker != id_defender and is_current_player(game.match, id_attacker) and
         Player.is_exposed(defender) do
      attacker = Utils.keyfind(game.match.players, id_attacker)
      amount = min(attacker.attack, defender.hp)

      game =
        update_player(game, id_attacker, fn player -> update_in(player.attack, &(&1 - amount)) end)
        |> update_player(id_defender, fn player -> update_in(player.hp, &(&1 - amount)) end)

      {:reply, :ok, game}
    else
      {:reply, {:error, :forbidden}, game}
    end
  end

  def handle_update({:end_turn, id_player}, _from, game) do
    if is_current_player(game.match, id_player) do
      game =
        clear_cards(game, id_player)
        |> set_current_player(Player.next(game.match.players, id_player))

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
    on_shuffle_discard = fn n -> Utils.update_self_after(1000, {:player_draw, id_player, n}) end
    update_player(game, id_player, &Player.draw_cards(&1, id_player, n, on_shuffle_discard))
  end

  defp find_card(match, id_card) do
    Enum.find_value(match.players, fn {id_player, player} ->
      Enum.find_value(player.cards, fn {zone, cards} ->
        find_card(cards, id_card, zone, id_player)
      end)
    end) ||
      find_card(match.gems, id_card, :gems) ||
      find_card(match.market, id_card, :market)
  end

  defp find_card(enum, id_card, zone, id_player \\ nil) do
    Enum.find_value(enum, fn {id, card} ->
      if id == id_card, do: {id_player, zone, {id_card, card}}, else: nil
    end)
  end

  defp buy_card(game, id_player, zone, {id_card, card}) do
    case Card.fetch(card).cost do
      cost when is_integer(cost) ->
        if Utils.keyfind(game.match.players, id_player).gold >= cost do
          {:reply, :ok, buy_card(game, id_player, zone, {id_card, card}, cost)}
        else
          {:reply, {:error, :forbidden}, game}
        end
    end
  end

  defp buy_card(game, id_player, zone, card, cost) do
    case zone do
      :market ->
        Utils.update_self_after(1000, :refill_market)

        update_in(game.match.market, fn market ->
          i = Enum.find_index(market, fn c -> c == card end)
          List.replace_at(market, i, nil)
        end)

      :gems ->
        update_in(game.match.gems, fn gems -> Enum.reject(gems, &(&1 == card)) end)
    end
    |> update_player(id_player, fn player ->
      update_in(player.cards.discard, &([card] ++ &1))
      |> update_in([:gold], &(&1 - cost))
    end)
  end

  defp play_own_card(game, id_player, :hand, card) do
    game =
      update_player(game, id_player, fn player ->
        update_in(player.cards.hand, &Enum.filter(&1, fn c -> c != card end))
        |> update_in([:cards, :fight_zone], &(&1 ++ [card]))
      end)
      |> Card.primary_effect(elem(card, 1))

    {:reply, :ok, game}
  end

  defp play_own_card(game, _id_player, _zone, _card), do: {:reply, {:error, :forbidden}, game}

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
