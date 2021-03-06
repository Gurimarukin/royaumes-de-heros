defmodule Heros.Game do
  @doc """

  ## Interactions:

  pending -> interaction:

    {:select_effect, effects} -> {:select_effect, index}

    :prepare_champion -> {:prepare_champion, card_id}

    :stun_champion -> {:stun_champion, defender_id, card_id}

    :put_card_from_discard_to_deck -> {:put_card_from_discard_to_deck, card_id}

    :put_champion_from_discard_to_deck -> {:put_champion_from_discard_to_deck, card_id}

    args = %{amount: amount, combat_per_card: combat_per_card}
    {:sacrifice_from_hand_or_discard, args} -> {:sacrifice_from_hand_or_discard, card_ids}

    :target_opponent_to_discard -> {:target_opponent_to_discard, nil}
    :target_opponent_to_discard -> {:target_opponent_to_discard, defender_id}

    :draw_then_discard -> {:draw_then_discard, false}
    :draw_then_discard -> {:draw_then_discard, true}

    :discard_card -> {:discard_card, card_id}


  ## Effects:

  {:heal, amount}
  {:heal_for_champions, {base, per_champion}}
  {:add_gold, amount}
  {:add_combat, amount}


  ## Temporary effects:

  :put_next_purchased_action_on_deck
  :put_next_purchased_card_in_hand
  :put_next_purchased_card_on_deck

  """

  alias Heros.Game
  alias Heros.Game.{Cards, Helpers, Player}
  alias Heros.Game.Cards.Card
  alias Heros.Utils.{KeyList, Option}

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
    |> KeyList.map(fn i ->
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

  @spec surrender(Game.t(), Player.id()) :: update()
  def surrender(game, player_id) do
    with_member(game.players, player_id, &Option.some(&1))
    |> Option.filter(fn p ->
      KeyList.count(game.players, &Player.alive?/1) > 1 and Player.alive?(p)
    end)
    |> Option.map(fn _ -> update_player(game, player_id, &Player.surrender/1) end)
    |> Option.chain(&player_might_be_dead(&1, player_id))
  end

  # Main phase

  @spec play_card(Game.t(), Player.id(), Card.id()) :: update()
  def play_card(game, player_id, card_id) do
    main_phase_action(game, player_id, fn player ->
      with_member(player.hand, card_id, fn card ->
        game =
          game
          |> update_player(player_id, &Player.move_from_hand_to_fight_zone(&1, {card_id, card}))

        Card.primary_ability(card.key)
        |> Option.from_nilable()
        |> Option.map(fn f -> f.(game, player_id) end)
        |> Option.alt(fn -> Option.some(game) end)
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
    Card.expend_ability(card.key)
    |> Option.from_nilable()
    |> Option.map(fn f ->
      game
      |> f.(player_id, card_id)
      |> update_player(player_id, &Player.expend_card(&1, card_id))
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
    KeyList.count(cards, &(Card.faction(&1.key) == faction))
  end

  defp use_ally_ability_bis(game, player_id, {card_id, card}) do
    Card.ally_ability(card.key)
    |> Option.from_nilable()
    |> Option.map(fn f ->
      game
      |> f.(player_id)
      |> update_player(player_id, &Player.consume_ally_ability(&1, card_id))
    end)
  end

  @spec use_ally_ability(Game.t(), Player.id(), Card.id()) :: update()
  def use_sacrifice_ability(game, player_id, card_id) do
    main_phase_action(game, player_id, fn player ->
      with_member(player.fight_zone, card_id, fn card ->
        Card.sacrifice_ability(card.key)
        |> Option.from_nilable()
        |> Option.map(fn f ->
          game
          |> update_player(player_id, &Player.remove_from_fight_zone(&1, card_id))
          |> add_to_gems_or_cemetery({card_id, Card.get(card.key)})
          |> f.(player_id)
        end)
      end)
    end)
  end

  @spec buy_card(Game.t(), Player.id(), Card.id()) :: update()
  def buy_card(game, player_id, card_id) do
    main_phase_action(game, player_id, fn player ->
      case KeyList.find(game.market, card_id) do
        nil ->
          with_member(game.gems, card_id, fn card ->
            buy_gem(game, {player_id, player}, {card_id, card})
          end)

        card ->
          buy_market_card(game, {player_id, player}, {card_id, card})
      end
    end)
  end

  defp buy_card_bis(game, {player_id, player}, {card_id, card}, f) do
    Player.buy_card(player, {card_id, card})
    |> Option.map(fn player ->
      game
      |> update_player(player_id, fn _ -> player end)
      |> f.(card_id)
    end)
  end

  defp buy_market_card(game, {player_id, player}, {card_id, card}) do
    buy_card_bis(game, {player_id, player}, {card_id, card}, &remove_from_market_and_refill/2)
  end

  defp buy_gem(game, {player_id, player}, {card_id, card}) do
    buy_card_bis(game, {player_id, player}, {card_id, card}, &remove_from_gems/2)
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
      Option.none()
    else
      damages = min(attacker.combat, defender.hp)

      game
      |> update_player(attacker_id, &Player.decr_combat(&1, damages))
      |> update_player(defender_id, &Player.decr_hp(&1, damages))
      |> player_might_be_dead(defender_id)
    end
  end

  defp attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, card_id) do
    with_member(defender.fight_zone, card_id, fn card ->
      attack_card(game, {attacker_id, attacker}, {defender_id, defender}, {card, card_id})
    end)
  end

  defp player_might_be_dead(game, player_id) do
    with_member(game.players, player_id, fn player ->
      if Player.alive?(player) do
        Option.some(game)
      else
        game = game |> update_player(player_id, &Player.full_discard/1)

        case Enum.filter(game.players, fn {_, p} -> Player.alive?(p) end) do
          [{winner_id, _}] ->
            {:victory, winner_id, game}

          _ ->
            Option.some(
              if game.current_player == player_id do
                set_current_player(game, next_player_alive(game, player_id))
              else
                game
              end
            )
        end
      end
    end)
  end

  defp attack_card(game, {attacker_id, attacker}, {defender_id, defender}, {card, card_id}) do
    # TODO: take defense modifiers into account
    case Card.type(card.key) do
      {:guard, defense} ->
        attack_card_bis(game, {attacker_id, attacker}, defender_id, {card_id, card}, defense)

      {:not_guard, defense} ->
        defender_has_guard = Enum.any?(defender.fight_zone, fn {_, c} -> Card.guard?(c.key) end)

        if defender_has_guard do
          Option.none()
        else
          attack_card_bis(game, {attacker_id, attacker}, defender_id, {card_id, card}, defense)
        end

      _ ->
        Option.none()
    end
  end

  defp attack_card_bis(game, {attacker_id, attacker}, defender_id, {card_id, card}, defense) do
    if defense <= attacker.combat do
      game
      |> update_player(attacker_id, &Player.decr_combat(&1, defense))
      |> update_player(
        defender_id,
        &Player.move_from_fight_zone_to_discard(&1, {card_id, Card.full_reset(card)})
      )
      |> Option.some()
    else
      Option.none()
    end
  end

  # Interactions (when user needs to perform an additionnal action, like
  # choosing between two effects or choosing a card to discard or to sacrifice)

  @spec interact(Game.t(), Player.id(), any) :: update()
  def interact(game, player_id, interaction) do
    with_member(game.players, player_id, fn player ->
      case player.pending_interactions do
        [] ->
          Option.none()

        [head | tail] ->
          game
          |> update_player(player_id, &Player.set_pending_interactions(&1, tail))
          |> interaction(player_id, head, interaction)
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
          Option.none()
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
         player_id,
         :put_card_from_discard_to_deck,
         {:put_card_from_discard_to_deck, card_id}
       ) do
    put_card_from_discard_to_deck(
      game,
      player_id,
      card_id,
      Helpers.interaction_filter(:put_card_from_discard_to_deck)
    )
  end

  defp interaction(
         game,
         player_id,
         :put_champion_from_discard_to_deck,
         {:put_champion_from_discard_to_deck, card_id}
       ) do
    put_card_from_discard_to_deck(
      game,
      player_id,
      card_id,
      Helpers.interaction_filter(:put_champion_from_discard_to_deck)
    )
  end

  defp interaction(
         game,
         player_id,
         {:sacrifice_from_hand_or_discard, args},
         {:sacrifice_from_hand_or_discard, card_ids}
       ) do
    %{amount: amount, combat_per_card: combat_per_card} = args

    game = Option.some(game) |> Option.filter(fn _ -> length(card_ids) <= amount end)

    Enum.reduce(card_ids, game, fn card_id, acc ->
      Option.chain(acc, fn game ->
        with_member(game.players, player_id, fn player ->
          sacrifice = sacrifice_from(game, player_id, card_id, combat_per_card)

          sacrifice.(player.hand, &Player.remove_from_hand/2)
          |> Option.alt(fn -> sacrifice.(player.discard, &Player.remove_from_discard/2) end)
        end)
      end)
    end)
  end

  defp interaction(
         game,
         _attacker_id,
         :target_opponent_to_discard,
         {:target_opponent_to_discard, nil}
       ),
       do: Option.some(game)

  defp interaction(
         game,
         _attacker_id,
         :target_opponent_to_discard,
         {:target_opponent_to_discard, defender_id}
       ) do
    with_member(game.players, defender_id, fn player ->
      if length(player.hand) == 0 do
        Option.none()
      else
        queue_discard_card(game, defender_id)
        |> Option.some()
      end
    end)
  end

  defp interaction(game, player_id, :draw_then_discard, {:draw_then_discard, false}) do
    game
    |> update_player(player_id, &Player.pop_interactions(&1, :draw_then_discard))
    |> Option.some()
  end

  defp interaction(game, player_id, :draw_then_discard, {:draw_then_discard, true}) do
    with_member(game.players, player_id, fn player -> Option.some(length(player.hand)) end)
    |> Option.chain(fn n_cards_before ->
      game = game |> draw_card(player_id, 1)

      with_member(game.players, player_id, fn player ->
        if length(player.hand) == n_cards_before + 1 do
          game
          |> queue_discard_card(player_id)
          |> Option.some()
        else
          Option.none()
        end
      end)
    end)
  end

  defp interaction(game, player_id, :discard_card, {:discard_card, card_id}) do
    discard_card(game, player_id, card_id, fn _ -> true end)
  end

  defp interaction(_game, _player_id, _pending, _interaction), do: Option.none()

  defp stun_champion(game, {defender_id, defender}, {card_id, card}) do
    case Card.type(card.key) do
      {:guard, _} ->
        game
        |> update_player(
          defender_id,
          &Player.move_from_fight_zone_to_discard(&1, {card_id, card})
        )
        |> Option.some()

      {:not_guard, _} ->
        defender_has_guard = Enum.any?(defender.fight_zone, fn {_, c} -> Card.guard?(c.key) end)

        game
        |> update_player(
          defender_id,
          &Player.move_from_fight_zone_to_discard(&1, {card_id, card})
        )
        |> Option.some()
        |> Option.filter(fn _ -> not defender_has_guard end)

      nil ->
        Option.none()
    end
  end

  @spec put_card_from_discard_to_deck(
          Game.t(),
          Player.id(),
          nil | Card.id(),
          (Card.t() -> boolean)
        ) ::
          {:ok, Game.t()} | :error
  defp put_card_from_discard_to_deck(game, _player_id, nil, _filter), do: Option.some(game)

  defp put_card_from_discard_to_deck(game, player_id, card_id, filter) do
    with_member(game.players, player_id, fn player ->
      with_member(player.discard, card_id, fn card ->
        game
        |> update_player(player_id, &Player.move_from_discard_to_deck(&1, {card_id, card}))
        |> Option.some()
        |> Option.filter(fn _ -> filter.(card) end)
      end)
    end)
  end

  @spec sacrifice_from(
          Game.t(),
          Player.id(),
          Card.id(),
          integer
        ) ::
          (list({Card.id(), Card.t()}), (Player.t(), Card.id() -> Player.t()) ->
             {:ok, Game.t()} | :error)
  defp sacrifice_from(game, player_id, card_id, combat_gained) do
    fn cards, remove ->
      with_member(cards, card_id, fn card ->
        game
        |> update_player(player_id, fn player ->
          player
          |> remove.(card_id)
          |> Player.incr_combat(combat_gained)
        end)
        |> add_to_cemetery({card_id, card})
        |> Option.some()
      end)
    end
  end

  defp discard_card(game, player_id, card_id, filter) do
    with_member(game.players, player_id, fn player ->
      with_member(player.hand, card_id, fn card ->
        game
        |> update_player(player_id, &Player.move_from_hand_to_discard(&1, {card_id, card}))
        |> Option.some()
        |> Option.filter(fn _ -> filter.(card) end)
      end)
    end)
  end

  # Discard phase (no real reason to separate it from Draw phase, but well...)

  @spec discard_phase(Game.t(), Player.id()) :: update()
  def discard_phase(game, player_id) do
    current_player_action(game, player_id, fn player ->
      if player.discard_phase_done do
        Option.none()
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
    KeyList.find(list, key)
    |> Option.from_nilable()
    |> Option.chain(f)
  end

  # player_id needs to be current player and no interaction is pending
  defp main_phase_action(game, player_id, f) do
    current_player_action(game, player_id, fn player ->
      if player.discard_phase_done do
        Option.none()
      else
        case player.pending_interactions do
          [] -> f.(player)
          _ -> Option.none()
        end
      end
    end)
  end

  # player_id needs to be current player
  defp current_player_action(game, player_id, f) do
    if game.current_player == player_id do
      with_member(game.players, player_id, f)
    else
      Option.none()
    end
  end

  # targeting other players
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

  def player(game, player_id), do: KeyList.find(game.players, player_id)

  # private setters
  defp set_current_player(game, player_id), do: %{game | current_player: player_id}

  defp add_to_gems_or_cemetery(game, {card_id, card}) do
    if card.key == :gem do
      add_to_gems(game, {card_id, card})
    else
      add_to_cemetery(game, {card_id, card})
    end
  end

  defp add_to_gems(game, {card_id, card}) do
    %{game | gems: [{card_id, card} | game.gems]}
  end

  defp remove_from_gems(game, card_id) do
    %{game | gems: game.gems |> KeyList.delete(card_id)}
  end

  defp add_to_cemetery(game, {card_id, card}) do
    %{game | cemetery: [{card_id, card} | game.cemetery]}
  end

  defp remove_from_market_and_refill(game, card_id) do
    {new_card, market_deck} =
      case game.market_deck do
        [] -> {nil, []}
        [new_card | market_deck] -> {new_card, market_deck}
      end

    %{game | market_deck: market_deck}
    |> replace_market_card(card_id, new_card)
  end

  # new_card can be {Card.id(), Card.t()} or nil
  defp replace_market_card(game, card_id, new_card) do
    %{game | market: game.market |> KeyList.fullreplace(card_id, new_card)}
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
      champions = KeyList.count(player.fight_zone, &Card.champion?(&1.key))
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
    %{game | players: game.players |> KeyList.update(player_id, f)}
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

  defp queue_interaction(game, player_id, interaction) do
    update_player(game, player_id, &Player.queue_interaction(&1, interaction))
  end

  def queue_select_effect(game, player_id, effects) do
    queue_interaction(game, player_id, {:select_effect, effects})
  end

  def queue_prepare_champion(game, player_id) do
    update_player(game, player_id, fn player ->
      expended_champions =
        KeyList.count(
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
    targetable_champion? =
      Enum.any?(game.players, fn {other_player_id, other_player} ->
        # next_to_player? makes sure that other_player is alive
        Game.next_to_player?(game, player_id, other_player_id) and
          Enum.any?(other_player.fight_zone, fn {_, c} -> Card.champion?(c.key) end)
      end)

    if targetable_champion? do
      game |> queue_interaction(player_id, :stun_champion)
    else
      game
    end
  end

  def queue_put_card_from_discard_to_deck(game, player_id) do
    update_player(game, player_id, fn player ->
      cards_in_discard =
        KeyList.count(
          player.discard,
          Helpers.interaction_filter(:put_card_from_discard_to_deck)
        )

      if cards_in_discard == 0 do
        player
      else
        player |> Player.queue_interaction(:put_card_from_discard_to_deck)
      end
    end)
  end

  def queue_put_champion_from_discard_to_deck(game, player_id) do
    update_player(game, player_id, fn player ->
      champions_in_discard =
        KeyList.count(
          player.discard,
          Helpers.interaction_filter(:put_champion_from_discard_to_deck)
        )

      if champions_in_discard == 0 do
        player
      else
        player |> Player.queue_interaction(:put_champion_from_discard_to_deck)
      end
    end)
  end

  # combat_gained: combat gained when sacrificing a card
  @spec queue_sacrifice_from_hand_or_discard(
          Game.t(),
          Player.id(),
          nil | list({:amount, integer} | {:combat_per_card, integer})
        ) :: Game.t()
  def queue_sacrifice_from_hand_or_discard(game, player_id, opts \\ []) do
    args = %{
      amount: opts[:amount] || 1,
      combat_per_card: opts[:combat_per_card] || 0
    }

    update_player(game, player_id, fn player ->
      sacrificeable_cards = length(player.hand) + length(player.discard)

      if sacrificeable_cards == 0 do
        player
      else
        player |> Player.queue_interaction({:sacrifice_from_hand_or_discard, args})
      end
    end)
  end

  def queue_target_opponent_to_discard(game, player_id) do
    targetable_player? =
      Enum.any?(game.players, fn {other_player_id, other_player} ->
        # next_to_player? makes sure that other_player is alive
        Game.next_to_player?(game, player_id, other_player_id) and
          0 < length(other_player.hand)
      end)

    if targetable_player? do
      game |> queue_interaction(player_id, :target_opponent_to_discard)
    else
      game
    end
  end

  def queue_draw_then_discard(game, player_id, amount \\ 1) do
    update_player(game, player_id, fn player ->
      amount = min(amount, length(player.deck) + length(player.discard))

      List.duplicate(nil, amount)
      |> Enum.reduce(player, fn _, player ->
        player |> Player.queue_interaction(:draw_then_discard)
      end)
    end)
  end

  defp queue_discard_card(game, player_id) do
    game |> queue_interaction(player_id, :discard_card)
  end

  def add_temporary_effect(game, player_id, effect) do
    update_player(game, player_id, &Player.add_temporary_effect(&1, effect))
  end
end
