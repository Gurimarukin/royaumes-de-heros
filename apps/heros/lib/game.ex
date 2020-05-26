defmodule Heros.Game do
  # use GenServer, restart: :temporary

  # require Logger

  alias Heros.{Cards, Game, KeyListUtils, Player}
  alias Heros.Cards.Card

  @type t :: %{
          players: list({Player.id(), Player.t()}),
          current_player: Player.id(),
          gems: list(Card.t()),
          market: list(nil | Card.t()),
          market_deck: list(Card.t()),
          cemetery: list(Card.t())
        }
  @enforce_keys [:players, :current_player, :gems, :market, :market_deck, :cemetery]
  defstruct [:players, :current_player, :gems, :market, :market_deck, :cemetery]

  def empty(players, current_player) do
    %Game{
      players: players,
      current_player: current_player,
      gems: [],
      market: [],
      market_deck: [],
      cemetery: []
    }
  end

  @spec init_from_players(list(Player.id())) :: {:ok, Game.t()} | :error
  def init_from_players(player_ids) do
    if valid_players?(player_ids) do
      {market, market_deck} = init_market()

      {:ok,
       %Game{
         players: init_players(player_ids),
         current_player: hd(player_ids),
         gems: Cards.gems(),
         market: market,
         market_deck: market_deck,
         cemetery: []
       }}
    else
      :error
    end
  end

  @spec valid_players?(list(Player.id())) :: boolean
  defp valid_players?(player_ids) do
    is_list(player_ids) and 2 <= length(player_ids)
  end

  defp init_players(player_ids) do
    n_players = length(player_ids)

    player_ids
    |> Enum.with_index()
    |> Enum.map(fn {player_id, i} ->
      {player_id,
       Player.init(
         cond do
           # first player always gets 3 cards
           i == 0 -> 3
           # when 2 players, second player gets 5 cards
           i == 1 && n_players == 2 -> 5
           # else, second player gets 4 cards
           i == 1 -> 4
           # other players get 5 cards
           true -> 5
         end
       )}
    end)
  end

  defp init_market do
    Cards.market()
    |> Enum.shuffle()
    |> Enum.split(5)
  end

  @spec play_card(Game.t(), {Player.id(), Player.t()}, {Card.id(), Card.t()}) :: Game.t()
  def play_card(game, {player_id, player}, {card_id, card}) do
    %{
      game
      | players:
          game.players
          |> KeyListUtils.replace(
            player_id,
            player
            |> Player.remove_from_hand(card_id)
            |> Player.add_to_fight_zone({card_id, card})
          )
    }
    |> Card.primary_ability(card.key, player_id)
  end

  @spec use_expend_ability(Game.t(), {Player.id(), Player.t()}, {Card.id(), Card.t()}) ::
          {:ok, Game.t()} | :error
  def use_expend_ability(game, {player_id, _player}, {card_id, card}) do
    case Card.expend_ability(game, card.key, player_id) do
      nil ->
        :error

      game ->
        {:ok,
         %{
           game
           | players:
               game.players
               |> KeyListUtils.update(
                 player_id,
                 fn player ->
                   %{
                     player
                     | fight_zone:
                         player.fight_zone |> KeyListUtils.update(card_id, &Card.expend/1)
                   }
                 end
               )
         }}
    end
  end

  @spec use_ally_ability(Game.t(), {Player.id(), Player.t()}, {Card.id(), Card.t()}) ::
          {:ok, Game.t()} | :error
  def use_ally_ability(game, {player_id, _player}, {card_id, card}) do
    case Card.ally_ability(game, card.key, player_id) do
      nil ->
        :error

      game ->
        {:ok,
         %{
           game
           | players:
               game.players
               |> KeyListUtils.update(
                 player_id,
                 fn player ->
                   %{
                     player
                     | fight_zone:
                         player.fight_zone
                         |> KeyListUtils.update(card_id, &Card.consume_ally_ability/1)
                   }
                 end
               )
         }}
    end
  end

  @spec buy_market_card(Game.t(), {Player.id(), Player.t()}, {Card.id(), Card.t()}) ::
          {:ok, Game.t()} | :error
  def buy_market_card(game, {player_id, player}, {card_id, card}) do
    case Player.card_cost_for_player(player, card) do
      nil ->
        :error

      cost ->
        if player.gold >= cost do
          {market_card, market_deck} =
            case game.market_deck do
              [] -> {nil, []}
              [market_card | market_deck] -> {market_card, market_deck}
            end

          {:ok,
           %{
             game
             | players:
                 game.players |> player_buy_card({player_id, player}, {card_id, card}, cost),
               market: game.market |> KeyListUtils.fullreplace(card_id, market_card),
               market_deck: market_deck
           }}
        else
          :error
        end
    end
  end

  @spec buy_gem(Game.t(), {Player.id(), Player.t()}, {Card.id(), Card.t()}) ::
          {:ok, Game.t()} | :error
  def buy_gem(game, {player_id, player}, {card_id, card}) do
    case Player.card_cost_for_player(player, card) do
      nil ->
        :error

      cost ->
        if player.gold >= cost do
          {:ok,
           %{
             game
             | players:
                 game.players |> player_buy_card({player_id, player}, {card_id, card}, cost),
               gems: game.gems |> KeyListUtils.delete(card_id)
           }}
        else
          :error
        end
    end
  end

  defp player_buy_card(players, {player_id, player}, {card_id, card}, cost) do
    players
    |> KeyListUtils.replace(
      player_id,
      player |> Player.buy_card({card_id, card}, cost)
    )
  end

  @spec next_player_alive(Game.t()) :: nil | Player.id()
  def next_player_alive(game) do
    case Enum.find_index(game.players, fn {id, _} -> id == game.current_player end) do
      nil -> nil
      i -> next_player_alive_rec(game.players, i)
    end
  end

  @spec previous_player_alive(Game.t()) :: nil | Player.id()
  def previous_player_alive(game) do
    case Enum.find_index(game.players, fn {id, _} -> id == game.current_player end) do
      nil -> nil
      i -> previous_player_alive_rec(game.players, i)
    end
  end

  defp next_player_alive_rec(players, i) do
    i = if i == length(players) - 1, do: 0, else: i + 1
    step_if_dead(players, i, &next_player_alive_rec/2)
  end

  defp previous_player_alive_rec(players, i) do
    i = if i == 0, do: length(players) - 1, else: i - 1
    step_if_dead(players, i, &previous_player_alive_rec/2)
  end

  defp step_if_dead(players, i, f) do
    case Enum.fetch(players, i) do
      {:ok, {k, p}} -> if Player.is_alive(p), do: k, else: f.(players, i)
      :error -> nil
    end
  end

  @spec is_next_to_current_player(Game.t(), Player.id()) :: boolean
  def is_next_to_current_player(game, player_id) do
    case next_player_alive(game) do
      nil ->
        false

      ^player_id ->
        true

      _ ->
        case previous_player_alive(game) do
          nil -> false
          ^player_id -> true
          _ -> false
        end
    end
  end

  # attack
  @spec attack_player(Game.t(), {Player.id(), Player.t()}, {Player.id(), Player.t()}) ::
          {:ok, Game.t()} | :error
  def attack_player(game, {attacker_id, attacker}, {defender_id, defender}) do
    defender_has_guard = Enum.any?(defender.fight_zone, fn {_, c} -> Card.is_guard(c.key) end)

    if defender_has_guard or not Player.is_alive(defender) do
      :error
    else
      damages = min(attacker.combat, defender.hp)

      {:ok,
       %{
         game
         | players:
             game.players
             |> KeyListUtils.replace(attacker_id, attacker |> Player.decr_combat(damages))
             |> KeyListUtils.replace(defender_id, defender |> Player.decr_hp(damages))
       }}
    end
  end

  @spec attack_card(
          Game.t(),
          {Player.id(), Player.t()},
          {Player.id(), Player.t()},
          {Card.id(), Card.t()}
        ) :: {:ok, Game.t()} | :error
  def attack_card(game, {attacker_id, attacker}, {defender_id, defender}, {card_id, card}) do
    case Card.type(card.key) do
      {:guard, defense} ->
        attack_card_bis(
          game,
          {attacker_id, attacker},
          {defender_id, defender},
          {card_id, card},
          defense
        )

      {:not_guard, defense} ->
        defender_has_guard = Enum.any?(defender.fight_zone, fn {_, c} -> Card.is_guard(c.key) end)

        if defender_has_guard do
          :error
        else
          attack_card_bis(
            game,
            {attacker_id, attacker},
            {defender_id, defender},
            {card_id, card},
            defense
          )
        end

      nil ->
        :error
    end
  end

  @spec attack_card_bis(
          Game.t(),
          {Player.id(), Player.t()},
          {Player.id(), Player.t()},
          {Card.id(), Card.t()},
          integer
        ) :: {:ok, Game.t()} | :error
  defp attack_card_bis(
         game,
         {attacker_id, attacker},
         {defender_id, defender},
         {card_id, card},
         defense
       ) do
    if attacker.combat >= defense do
      {:ok,
       %{
         game
         | players:
             game.players
             |> KeyListUtils.replace(attacker_id, attacker |> Player.decr_combat(defense))
             |> KeyListUtils.replace(defender_id, %{
               defender
               | discard: [{card_id, card} | defender.discard],
                 fight_zone: defender.fight_zone |> KeyListUtils.delete(card_id)
             })
       }}
    else
      :error
    end
  end

  @spec discard_phase(Game.t(), Player.id()) :: Game.t()
  def discard_phase(game, player_id) do
    %{game | players: game.players |> KeyListUtils.update(player_id, &Player.discard_phase/1)}
  end

  @spec draw_phase(Game.t(), Player.id()) :: Game.t()
  def draw_phase(game, player_id) do
    %{
      game
      | players: game.players |> KeyListUtils.update(player_id, &Player.draw_cards(&1, 5)),
        current_player: next_player_alive(game)
    }
  end

  #
  # Helpers for abilities
  #

  def update_player(game, player_id, f) do
    %{game | players: game.players |> KeyListUtils.update(player_id, f)}
  end

  def heal(game, player_id, amount) do
    game
    |> update_player(player_id, fn player ->
      hp = player.hp + amount
      %{player | hp: min(hp, player.max_hp)}
    end)
  end

  def add_gold(game, player_id, amount) do
    game |> update_player(player_id, &Player.incr_gold(&1, amount))
  end

  def add_combat(game, player_id, amount) do
    game |> update_player(player_id, &Player.incr_combat(&1, amount))
  end

  def draw_card(game, player_id, amount) do
    game |> update_player(player_id, &Player.draw_cards(&1, amount))
  end
end
