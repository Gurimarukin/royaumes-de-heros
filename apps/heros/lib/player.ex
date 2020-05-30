defmodule Heros.Player do
  alias Heros.{Cards, KeyListUtils, Option, Player}
  alias Heros.Cards.Card

  @type id :: String.t()

  @type t :: %__MODULE__{
          pending_interactions: list(any),
          temporary_effects: list(any),
          discard_phase_done: boolean,
          hp: integer,
          max_hp: integer,
          gold: integer,
          combat: integer,
          hand: list(Card.t()),
          deck: list(Card.t()),
          discard: list(Card.t()),
          fight_zone: list(Card.t())
          # inventory: list(Card.t())
          # enemy_fight_zone: list(Card.t())
        }
  @enforce_keys [
    :pending_interactions,
    :temporary_effects,
    :discard_phase_done,
    :hp,
    :max_hp,
    :gold,
    :combat,
    :hand,
    :deck,
    :discard,
    :fight_zone
  ]
  defstruct [
    :pending_interactions,
    :temporary_effects,
    :discard_phase_done,
    :hp,
    :max_hp,
    :gold,
    :combat,
    :hand,
    :deck,
    :discard,
    :fight_zone
  ]

  def empty do
    %Player{
      pending_interactions: [],
      temporary_effects: [],
      discard_phase_done: false,
      hp: 50,
      max_hp: 50,
      gold: 0,
      combat: 0,
      hand: [],
      deck: [],
      discard: [],
      fight_zone: []
    }
  end

  @spec init(integer) :: Player.t()
  def init(n) do
    %{empty() | deck: Enum.shuffle(Cards.Decks.Base.get())}
    |> draw_cards(n)
  end

  @spec alive?(Player.t()) :: boolean
  def alive?(player), do: player.hp > 0

  @spec draw_cards(Player.t(), integer) :: Player.t()
  def draw_cards(player, n) do
    if n <= 0, do: player, else: draw_cards_rec(player, n)
  end

  defp draw_cards_rec(player, n) do
    case {player.deck, player.discard} do
      {[], []} ->
        player

      {[], discard} ->
        %{
          player
          | deck: Enum.shuffle(discard),
            discard: []
        }
        |> draw_cards(n)

      {[head | tail], _} ->
        %{
          player
          | hand: player.hand ++ [head],
            deck: tail
        }
        |> draw_cards(n - 1)
    end
  end

  @spec card_cost(Player.t(), Card.t()) :: {:ok, integer} | :error
  defp card_cost(_player, card) do
    Card.cost(card.key)
    |> Option.from_nilable()
  end

  @spec buy_card(Player.t(), {Card.id(), Card.t()}) :: {:ok, Player.t()} | :error
  def buy_card(player, {card_id, card}) do
    player
    |> card_cost(card)
    |> Option.filter(fn cost -> cost <= player.gold end)
    |> Option.map(fn cost ->
      player = player |> Player.decr_gold(cost)

      case try_effects(player, :on_buy, player.temporary_effects, {card_id, card}) do
        nil -> add_to_discard(player, {card_id, card})
        {player, index} -> remove_temporary_effect(player, index)
      end
    end)
  end

  defp try_effects(player, event, effects, card, i \\ 0)

  defp try_effects(_player, _event, [], {_card_id, _card}, _i), do: nil

  defp try_effects(player, event, [effect | tail], {card_id, card}, i) do
    case temporary_effect(player, event, effect, {card_id, card}) do
      nil -> try_effects(player, event, tail, {card_id, card}, i + 1)
      player -> {player, i}
    end
  end

  # temporary_effect shouldn't update player.temporary_effects
  # (except appending elements, which is just fine)
  defp temporary_effect(player, :on_buy, :put_next_purchased_action_on_deck, {card_id, card}) do
    if Card.action?(card.key) do
      %{player | deck: [{card_id, card} | player.deck]}
    else
      nil
    end
  end

  defp temporary_effect(player, :on_buy, :put_next_purchased_card_in_hand, {card_id, card}) do
    %{player | hand: player.hand ++ [{card_id, card}]}
  end

  defp temporary_effect(player, :on_buy, :put_next_purchased_card_on_deck, {card_id, card}) do
    %{player | deck: [{card_id, card} | player.deck]}
  end

  defp temporary_effect(_player, _event, _effect, {_card_id, _card}), do: nil

  #
  # Doing things with cards
  #

  def move_from_fight_zone_to_discard(player, {card_id, card}) do
    player
    |> remove_from_fight_zone(card_id)
    |> add_to_discard({card_id, Card.get(card.key)})
  end

  def move_from_hand_to_fight_zone(player, {card_id, card}) do
    player
    |> remove_from_hand(card_id)
    |> add_to_fight_zone({card_id, card})
  end

  def move_from_hand_to_discard(player, {card_id, card}) do
    player
    |> remove_from_hand(card_id)
    |> add_to_discard({card_id, card})
  end

  def move_from_discard_to_deck(player, {card_id, card}) do
    player
    |> remove_from_discard(card_id)
    |> add_to_deck({card_id, card})
  end

  def remove_from_hand(player, card_id) do
    %{player | hand: player.hand |> KeyListUtils.delete(card_id)}
  end

  def add_to_fight_zone(player, {card_id, card}) do
    %{player | fight_zone: player.fight_zone ++ [{card_id, card}]}
  end

  def remove_from_fight_zone(player, card_id) do
    %{player | fight_zone: player.fight_zone |> KeyListUtils.delete(card_id)}
  end

  def add_to_discard(player, {card_id, card}) do
    %{player | discard: [{card_id, card} | player.discard]}
  end

  def remove_from_discard(player, card_id) do
    %{player | discard: player.discard |> KeyListUtils.delete(card_id)}
  end

  def add_to_deck(player, {card_id, card}) do
    %{player | deck: [{card_id, card} | player.deck]}
  end

  def expend_card(player, card_id) do
    %{player | fight_zone: player.fight_zone |> KeyListUtils.update(card_id, &Card.expend/1)}
  end

  def prepare(player, card_id) do
    %{
      player
      | fight_zone: player.fight_zone |> KeyListUtils.update(card_id, &Card.prepare/1)
    }
  end

  def consume_ally_ability(player, card_id) do
    %{
      player
      | fight_zone:
          player.fight_zone |> KeyListUtils.update(card_id, &Card.consume_ally_ability/1)
    }
  end

  @spec discard_phase(Player.t()) :: Player.t()
  def discard_phase(player) do
    {champions, non_champions} =
      player.fight_zone |> Enum.split_with(fn {_, c} -> Card.champion?(c.key) end)

    %{
      player
      | pending_interactions: [],
        temporary_effects: [],
        discard_phase_done: true,
        gold: 0,
        combat: 0,
        hand: [],
        discard: Enum.reverse(player.hand) ++ Enum.reverse(non_champions) ++ player.discard,
        fight_zone: champions |> KeyListUtils.map(&Card.full_reset/1)
    }
  end

  @spec draw_phase(Player.t()) :: Player.t()
  def draw_phase(player) do
    %{player | discard_phase_done: false}
    |> draw_cards(5)
  end

  def set_pending_interactions(player, pending_interactions) do
    %{player | pending_interactions: pending_interactions}
  end

  def queue_interaction(player, interaction) do
    player |> set_pending_interactions(player.pending_interactions ++ [interaction])
  end

  def pop_interactions(player, interaction) do
    pending_interactions = player.pending_interactions |> Enum.drop_while(&(&1 == interaction))
    player |> set_pending_interactions(pending_interactions)
  end

  def add_temporary_effect(player, effect) do
    %{player | temporary_effects: player.temporary_effects ++ [effect]}
  end

  defp remove_temporary_effect(player, index) do
    %{player | temporary_effects: player.temporary_effects |> List.delete_at(index)}
  end

  def heal(player, amount) do
    hp = player.hp + amount
    %{player | hp: min(hp, player.max_hp)}
  end

  def decr_hp(player, amount), do: %{player | hp: player.hp - amount}

  def incr_gold(player, amount), do: %{player | gold: player.gold + amount}
  def decr_gold(player, amount), do: %{player | gold: player.gold - amount}

  def incr_combat(player, amount), do: %{player | combat: player.combat + amount}
  def decr_combat(player, amount), do: %{player | combat: player.combat - amount}
end
