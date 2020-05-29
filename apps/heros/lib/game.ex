defmodule Heros.Game do
  # use GenServer, restart: :temporary

  # require Logger

  alias Heros.{Cards, Game, KeyListUtils, Option, Player}
  alias Heros.Cards.Card

  @type t :: %__MODULE__{
          players: list({Player.id(), Player.t()}),
          current_player: Player.id(),
          gems: list(Card.t()),
          market: list(nil | Card.t()),
          market_deck: list(Card.t()),
          cemetery: list(Card.t())
        }
  @enforce_keys [:players, :current_player, :gems, :market, :market_deck, :cemetery]
  defstruct [:players, :current_player, :gems, :market, :market_deck, :cemetery]

  @type option :: {:ok, Game.t()} | :error
  @type update :: option() | {:victory, Player.id(), Game.t()}

  #
  # Init
  #

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

  @spec init_from_players(list(Player.id())) :: option()
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
    |> KeyListUtils.map(fn i ->
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
      )
    end)
  end

  defp init_market do
    Cards.market()
    |> Enum.shuffle()
    |> Enum.split(5)
  end

  #
  # Callable actions
  #

  # Main phase

  @spec play_card(Game.t(), Player.id(), Card.id()) :: update()
  def play_card(game, player_id, card_id) do
    main_phase_action(game, player_id, fn player ->
      with_member(player.hand, card_id, fn card ->
        %{
          game
          | players:
              game.players
              |> KeyListUtils.update(
                player_id,
                &(&1
                  |> Player.remove_from_hand(card_id)
                  |> Player.add_to_fight_zone({card_id, card}))
              )
        }
        |> Card.primary_ability(card.key, player_id)
        |> Option.some()
      end)
    end)
  end

  @spec use_expend_ability(Game.t(), Player.id(), Card.id()) :: update()
  def use_expend_ability(game, player_id, card_id) do
    main_phase_action(game, player_id, fn player ->
      with_member(player.fight_zone, card_id, fn card ->
        if card.expend_ability_used do
          Option.none()
        else
          use_expend_ability_bis(game, player_id, {card_id, card})
        end
      end)
    end)
  end

  defp use_expend_ability_bis(game, player_id, {card_id, card}) do
    Card.expend_ability(game, card.key, player_id, card_id)
    |> Option.from_nilable()
    |> Option.map(fn game ->
      update_player(game, player_id, fn player ->
        %{
          player
          | fight_zone: player.fight_zone |> KeyListUtils.update(card_id, &Card.expend/1)
        }
      end)
    end)
  end

  @spec use_ally_ability(Game.t(), Player.id(), Card.id()) :: update()
  def use_ally_ability(game, player_id, card_id) do
    main_phase_action(game, player_id, fn player ->
      with_member(player.fight_zone, card_id, fn card ->
        Card.faction(card.key)
        |> Option.from_nilable()
        |> Option.filter(fn faction ->
          not card.ally_ability_used and
            2 <= count_from_faction(player.fight_zone, faction)
        end)
        |> Option.chain(fn _ ->
          use_ally_ability_bis(game, player_id, {card_id, card})
        end)
      end)
    end)
  end

  defp count_from_faction(cards, faction) do
    KeyListUtils.count(cards, &(Card.faction(&1.key) == faction))
  end

  defp use_ally_ability_bis(game, player_id, {card_id, card}) do
    Card.ally_ability(game, card.key, player_id)
    |> Option.from_nilable()
    |> Option.map(fn game ->
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
      }
    end)
  end

  @spec use_ally_ability(Game.t(), Player.id(), Card.id()) :: update()
  def use_sacrifice_ability(game, player_id, card_id) do
    main_phase_action(game, player_id, fn player ->
      with_member(player.fight_zone, card_id, fn card ->
        Card.sacrifice_ability(game, card.key, player_id)
        |> Option.from_nilable()
        |> Option.map(fn game ->
          game =
            game
            |> update_player(player_id, &Player.remove_from_fight_zone(&1, card_id))

          reset_card = {card_id, Card.get(card.key)}

          if card.key == :gem do
            %{game | gems: [reset_card | game.gems]}
          else
            %{game | cemetery: [reset_card | game.cemetery]}
          end
        end)
      end)
    end)
  end

  @spec buy_card(Game.t(), Player.id(), Card.id()) :: update()
  def buy_card(game, player_id, card_id) do
    main_phase_action(game, player_id, fn player ->
      case KeyListUtils.find(game.market, card_id) do
        nil ->
          with_member(game.gems, card_id, fn card ->
            buy_gem(game, {player_id, player}, {card_id, card})
          end)

        card ->
          buy_market_card(game, {player_id, player}, {card_id, card})
      end
    end)
  end

  defp buy_market_card(game, {player_id, player}, {card_id, card}) do
    buy_card_bis(player, card, fn cost ->
      {market_card, market_deck} =
        case game.market_deck do
          [] -> {nil, []}
          [market_card | market_deck] -> {market_card, market_deck}
        end

      %{
        game
        | players: game.players |> player_buy_card(player_id, {card_id, card}, cost),
          market: game.market |> KeyListUtils.fullreplace(card_id, market_card),
          market_deck: market_deck
      }
    end)
  end

  defp buy_gem(game, {player_id, player}, {card_id, card}) do
    buy_card_bis(player, card, fn cost ->
      %{
        game
        | players: game.players |> player_buy_card(player_id, {card_id, card}, cost),
          gems: game.gems |> KeyListUtils.delete(card_id)
      }
    end)
  end

  defp buy_card_bis(player, card, f) do
    Player.card_cost_for_player(player, card)
    |> Option.from_nilable()
    |> Option.filter(fn cost -> cost <= player.gold end)
    |> Option.map(f)
  end

  defp player_buy_card(players, player_id, {card_id, card}, cost) do
    players
    |> KeyListUtils.update(
      player_id,
      &Player.buy_card(&1, {card_id, card}, cost)
    )
  end

  @spec attack(Game.t(), Player.id(), Player.id(), :attack | Card.id()) :: update()
  def attack(game, attacker_id, defender_id, what) do
    main_phase_action(game, attacker_id, fn attacker ->
      with_member(game.players, defender_id, fn defender ->
        if attacker.combat > 0 and next_to_current_player?(game, defender_id) do
          attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, what)
        else
          Option.none()
        end
      end)
    end)
  end

  defp attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, :player) do
    defender_has_guard = Enum.any?(defender.fight_zone, fn {_, c} -> Card.guard?(c.key) end)

    if defender_has_guard or not Player.alive?(defender) do
      :error
    else
      damages = min(attacker.combat, defender.hp)

      %{
        game
        | players:
            game.players
            |> KeyListUtils.update(attacker_id, &Player.decr_combat(&1, damages))
            |> KeyListUtils.update(defender_id, &Player.decr_hp(&1, damages))
      }
      |> check_victory(attacker_id)
    end
  end

  defp attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, card_id) do
    with_member(defender.fight_zone, card_id, fn card ->
      attack_card(game, {attacker_id, attacker}, {defender_id, defender}, {card, card_id})
    end)
  end

  defp check_victory(game, attacker_id) do
    players_alive = game.players |> KeyListUtils.count(&Player.alive?/1)

    if players_alive == 1 do
      {:victory, attacker_id, game}
    else
      Option.some(game)
    end
  end

  defp attack_card(game, {attacker_id, attacker}, {defender_id, defender}, {card, card_id}) do
    # TODO: take defense modifiers into account
    case Card.type(card.key) do
      {:guard, defense} ->
        attack_card_bis(game, {attacker_id, attacker}, defender_id, {card_id, card}, defense)

      {:not_guard, defense} ->
        defender_has_guard = Enum.any?(defender.fight_zone, fn {_, c} -> Card.guard?(c.key) end)

        if defender_has_guard do
          :error
        else
          attack_card_bis(game, {attacker_id, attacker}, defender_id, {card_id, card}, defense)
        end

      _ ->
        :error
    end
  end

  defp attack_card_bis(game, {attacker_id, attacker}, defender_id, {card_id, card}, defense) do
    if defense <= attacker.combat do
      %{
        game
        | players:
            game.players
            |> KeyListUtils.update(attacker_id, &Player.decr_combat(&1, defense))
            |> KeyListUtils.update(defender_id, &Player.stun_card(&1, {card_id, card}))
      }
      |> Option.some()
    else
      :error
    end
  end

  # Interactions (when user needs to perform an additionnal action, like
  # choosing between two effects or choosing a card to discard or to sacrifice)

  @spec interact(Game.t(), Player.id(), any) :: update()
  def interact(game, player_id, interaction) do
    current_player_action(game, player_id, fn player ->
      case player.pending_interactions do
        [] ->
          :error

        [head | tail] ->
          game
          |> update_player(player_id, &%{&1 | pending_interactions: tail})
          |> interaction(player_id, head, interaction)

        _ ->
          :error
      end
    end)
  end

  defp interaction(game, player_id, {:select_effect, effects}, {:select_effect, index}) do
    Enum.fetch(effects, index)
    |> Option.chain(fn effect -> apply_effect(game, player_id, effect) end)
  end

  defp interaction(game, player_id, :prepare_champion, {:prepare_champion, card_id}) do
    with_member(game.players, player_id, fn player ->
      with_member(player.fight_zone, card_id, fn card ->
        if Card.champion?(card.key) and card.expend_ability_used do
          game
          |> update_player(player_id, &Player.prepare(&1, card_id))
          |> Option.some()
        else
          :error
        end
      end)
    end)
  end

  defp interaction(game, attacker_id, :stun_champion, {:stun_champion, defender_id, card_id}) do
    with_member(game.players, defender_id, fn defender ->
      with_member(defender.fight_zone, card_id, fn card ->
        if next_to_player?(game, attacker_id, defender_id) do
          stun_champion(game, {defender_id, defender}, {card_id, card})
        else
          Option.none()
        end
      end)
    end)
  end

  defp interaction(
         game,
         _player_id,
         :put_card_from_discard_to_deck,
         {:put_card_from_discard_to_deck, nil}
       ),
       do: Option.some(game)

  defp interaction(
         game,
         player_id,
         :put_card_from_discard_to_deck,
         {:put_card_from_discard_to_deck, card_id}
       ) do
    with_member(game.players, player_id, fn player ->
      with_member(player.discard, card_id, fn card ->
        game
        |> update_player(player_id, fn player ->
          %{
            player
            | deck: [{card_id, card} | player.deck],
              discard: player.discard |> KeyListUtils.delete(card_id)
          }
        end)
        |> Option.some()
      end)
    end)
  end

  defp interaction(
         game,
         _player_id,
         :sacrifice_from_hand_or_discard,
         {:sacrifice_from_hand_or_discard, nil}
       ),
       do: Option.some(game)

  defp interaction(
         game,
         player_id,
         :sacrifice_from_hand_or_discard,
         {:sacrifice_from_hand_or_discard, card_id}
       ) do
    with_member(game.players, player_id, fn player ->
      sacrifice_from(game, player_id, player.hand, &Player.remove_from_hand/2, card_id)
      |> Option.alt(fn ->
        sacrifice_from(game, player_id, player.discard, &Player.remove_from_discard/2, card_id)
      end)
    end)
  end

  defp interaction(_game, _player_id, _pending, _interaction), do: Option.none()

  defp stun_champion(game, {defender_id, defender}, {card_id, card}) do
    case Card.type(card.key) do
      {:guard, _} ->
        update_player(game, defender_id, &Player.stun_card(&1, {card_id, card}))
        |> Option.some()

      {:not_guard, _} ->
        defender_has_guard = Enum.any?(defender.fight_zone, fn {_, c} -> Card.guard?(c.key) end)

        update_player(game, defender_id, &Player.stun_card(&1, {card_id, card}))
        |> Option.some()
        |> Option.filter(fn _ -> not defender_has_guard end)

      nil ->
        Option.none()
    end
  end

  @spec sacrifice_from(
          Game.t(),
          Player.id(),
          list({Card.id(), Card.t()}),
          (Player.t(), Card.id() -> Player.t()),
          Card.id()
        ) :: {:ok, Game.t()} | :error
  defp sacrifice_from(game, player_id, cards, remove, card_id) do
    with_member(cards, card_id, fn card ->
      game
      |> update_player(player_id, &remove.(&1, card_id))
      |> add_to_cemetery({card_id, card})
      |> Option.some()
    end)
  end

  # Discard phase (no real reason to separate it from Draw phase, but well...)

  @spec discard_phase(Game.t(), Player.id()) :: update()
  def discard_phase(game, player_id) do
    current_player_action(game, player_id, fn player ->
      if player.discard_phase_done do
        :error
      else
        update_player(game, player_id, &Player.discard_phase/1)
        |> Option.some()
      end
    end)
  end

  # Draw phase

  @spec draw_phase(Game.t(), Player.id()) :: update()
  def draw_phase(game, player_id) do
    current_player_action(game, player_id, fn player ->
      if player.discard_phase_done do
        game = game |> update_player(player_id, &Player.draw_phase/1)

        game
        |> set_current_player(next_player_alive(game, player_id))
        |> Option.some()
      else
        :error
      end
    end)
  end

  #
  # Helpers
  #

  defp with_member(list, key, f) do
    KeyListUtils.find(list, key)
    |> Option.from_nilable()
    |> Option.chain(f)
  end

  # player_id needs to be current player and no interaction is pending
  defp main_phase_action(game, player_id, f) do
    current_player_action(game, player_id, fn player ->
      case player.pending_interactions do
        [] -> f.(player)
        _ -> Option.none()
      end
    end)
  end

  # player_id needs to be current player
  defp current_player_action(game, player_id, f) do
    if game.current_player == player_id do
      case player(game, player_id) do
        nil -> Option.none()
        p -> f.(p)
      end
    else
      Option.none()
    end
  end

  @spec next_player_alive(Game.t(), Player.id()) :: nil | Player.id()
  defp next_player_alive(game, player_id) do
    case Enum.find_index(game.players, fn {id, _} -> id == player_id end) do
      nil -> nil
      i -> next_player_alive_rec(game.players, player_id, i)
    end
  end

  @spec previous_player_alive(Game.t(), Player.id()) :: nil | Player.id()
  defp previous_player_alive(game, player_id) do
    case Enum.find_index(game.players, fn {id, _} -> id == player_id end) do
      nil -> nil
      i -> previous_player_alive_rec(game.players, player_id, i)
    end
  end

  defp next_player_alive_rec(players, player_id, i) do
    i = if i == length(players) - 1, do: 0, else: i + 1
    step_if_dead(players, player_id, i, &next_player_alive_rec/3)
  end

  defp previous_player_alive_rec(players, player_id, i) do
    i = if i == 0, do: length(players) - 1, else: i - 1
    step_if_dead(players, player_id, i, &previous_player_alive_rec/3)
  end

  defp step_if_dead(players, player_id, i, f) do
    case Enum.fetch(players, i) do
      {:ok, {k, p}} -> if Player.alive?(p), do: k, else: f.(players, player_id, i)
      :error -> nil
    end
  end

  @spec next_to_current_player?(Game.t(), Player.id()) :: boolean
  defp next_to_current_player?(game, other_player_id) do
    next_to_player?(game, game.current_player, other_player_id)
  end

  @spec next_to_player?(Game.t(), Player.id(), Player.id()) :: boolean
  def next_to_player?(game, player_id, other_player_id) do
    case next_player_alive(game, player_id) do
      nil ->
        false

      ^other_player_id ->
        true

      _ ->
        case previous_player_alive(game, player_id) do
          nil -> false
          ^other_player_id -> true
          _ -> false
        end
    end
  end

  def player(game, player_id), do: KeyListUtils.find(game.players, player_id)

  defp set_current_player(game, player_id), do: %{game | current_player: player_id}

  defp add_to_cemetery(game, {card_id, card}) do
    %{game | cemetery: [{card_id, card} | game.cemetery]}
  end

  # when you have to chose between two effects
  # (has nothing to do with temporary effects)
  @spec apply_effect(Game.t(), Player.id(), {atom, any}) :: {:ok, Game.t()} | :error
  defp apply_effect(game, player_id, {:heal, amount}) do
    update_player(game, player_id, &Player.heal(&1, amount))
    |> Option.some()
  end

  defp apply_effect(game, player_id, {:heal_for_champions, {base, per_champion}}) do
    update_player(game, player_id, fn player ->
      champions = KeyListUtils.count(player.fight_zone, &Card.champion?(&1.key))
      player |> Player.heal(base + champions * per_champion)
    end)
    |> Option.some()
  end

  defp apply_effect(game, player_id, {:add_gold, amount}) do
    update_player(game, player_id, &Player.incr_gold(&1, amount))
    |> Option.some()
  end

  defp apply_effect(game, player_id, {:add_combat, amount}) do
    update_player(game, player_id, &Player.incr_combat(&1, amount))
    |> Option.some()
  end

  defp apply_effect(_game, _player_id, _effect), do: :error

  #
  # Helpers for card abilities
  #

  @spec update_player(%{players: [tuple]}, any, any) :: %{players: [tuple]}
  def update_player(game, player_id, f) do
    %{game | players: game.players |> KeyListUtils.update(player_id, f)}
  end

  def heal(game, player_id, amount) do
    {:ok, game} = apply_effect(game, player_id, {:heal, amount})
    game
  end

  def add_gold(game, player_id, amount) do
    {:ok, game} = apply_effect(game, player_id, {:add_gold, amount})
    game
  end

  def add_combat(game, player_id, amount) do
    {:ok, game} = apply_effect(game, player_id, {:add_combat, amount})
    game
  end

  def draw_card(game, player_id, amount) do
    update_player(game, player_id, &Player.draw_cards(&1, amount))
  end

  def queue_interaction(game, player_id, interaction) do
    update_player(game, player_id, &Player.queue_interaction(&1, interaction))
  end

  def queue_prepare_champion(game, player_id) do
    update_player(game, player_id, fn player ->
      expended_champions =
        KeyListUtils.count(
          player.fight_zone,
          fn c -> Card.champion?(c.key) and c.expend_ability_used end
        )

      if expended_champions == 0 do
        player
      else
        player |> Player.queue_interaction(:prepare_champion)
      end
    end)
  end

  def queue_stun_champion(game, player_id) do
    are_targetable_champions =
      Enum.any?(game.players, fn {other_player_id, other_player} ->
        # next_to_player? makes sure that other_player is alive
        Game.next_to_player?(game, player_id, other_player_id) and
          Enum.any?(other_player.fight_zone, fn {_, c} -> Card.champion?(c.key) end)
      end)

    if are_targetable_champions do
      game |> Game.queue_interaction(player_id, :stun_champion)
    else
      game
    end
  end

  def queue_sacrifice_from_hand_or_discard(game, player_id) do
    case KeyListUtils.find(game.players, player_id) do
      nil ->
        game

      player ->
        sacrificeable_cards = length(player.hand) + length(player.discard)

        if 1 <= sacrificeable_cards do
          queue_interaction(game, player_id, :sacrifice_from_hand_or_discard)
        else
          game
        end
    end
  end

  def add_temporary_effect(game, player_id, effect) do
    update_player(game, player_id, &Player.add_temporary_effect(&1, effect))
  end
end
