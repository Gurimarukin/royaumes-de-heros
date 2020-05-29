defmodule Heros.Cards.Necros do
  alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

  @spec get :: list({Card.id(), Card.t()})
  def get do
    Cards.with_id(:cult_priest, 2) ++
      Cards.with_id(:dark_energy) ++
      Cards.with_id(:dark_reward) ++
      Cards.with_id(:death_cultist, 2) ++
      Cards.with_id(:death_touch, 3) ++
      Cards.with_id(:rayla) ++
      Cards.with_id(:influence, 3) ++
      Cards.with_id(:krythos) ++
      Cards.with_id(:life_drain) ++
      Cards.with_id(:lys) ++
      Cards.with_id(:the_rot, 2) ++
      Cards.with_id(:tyrannor) ++
      Cards.with_id(:varrick)
  end

  @spec cost(atom) :: nil | integer
  def cost(:cult_priest), do: 3
  def cost(:dark_energy), do: 4
  def cost(:dark_reward), do: 5
  def cost(:death_cultist), do: 2
  def cost(:death_touch), do: 1
  def cost(:rayla), do: 4
  def cost(:influence), do: 2
  def cost(:krythos), do: 7
  def cost(:life_drain), do: 6
  def cost(:lys), do: 6
  def cost(:the_rot), do: 3
  def cost(:tyrannor), do: 8
  def cost(:varrick), do: 5
  def cost(_), do: nil

  @spec type(atom) :: nil | :item | :action | {:guard | :not_guard, integer}
  def type(:cult_priest), do: {:not_guard, 4}
  def type(:dark_energy), do: :action
  def type(:dark_reward), do: :action
  def type(:death_cultist), do: {:guard, 3}
  def type(:death_touch), do: :action
  def type(:rayla), do: {:not_guard, 4}
  def type(:influence), do: :action
  def type(:krythos), do: {:not_guard, 6}
  def type(:life_drain), do: :action
  def type(:lys), do: {:guard, 5}
  def type(:the_rot), do: :action
  def type(:tyrannor), do: {:guard, 6}
  def type(:varrick), do: {:not_guard, 3}
  def type(_), do: nil

  @spec faction(atom) :: nil | :necros
  def faction(:cult_priest), do: :necros
  def faction(:dark_energy), do: :necros
  def faction(:dark_reward), do: :necros
  def faction(:death_cultist), do: :necros
  def faction(:death_touch), do: :necros
  def faction(:rayla), do: :necros
  def faction(:influence), do: :necros
  def faction(:krythos), do: :necros
  def faction(:life_drain), do: :necros
  def faction(:lys), do: :necros
  def faction(:the_rot), do: :necros
  def faction(:tyrannor), do: :necros
  def faction(:varrick), do: :necros
  def faction(_), do: nil

  # Primary ablilities

  @spec primary_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def primary_ability(game, :dark_energy, player_id) do
    game |> Game.add_combat(player_id, 7)
  end

  def primary_ability(game, :dark_reward, player_id) do
    game
    |> Game.add_gold(player_id, 3)
    |> Game.queue_sacrifice_from_hand_or_discard(player_id)
  end

  def primary_ability(game, :death_touch, player_id) do
    game
    |> Game.add_combat(player_id, 2)
    |> Game.queue_sacrifice_from_hand_or_discard(player_id)
  end

  def primary_ability(game, :influence, player_id) do
    game |> Game.add_gold(player_id, 3)
  end

  def primary_ability(game, :life_drain, player_id) do
    game
    |> Game.add_combat(player_id, 8)
    |> Game.queue_sacrifice_from_hand_or_discard(player_id)
  end

  def primary_ability(game, :the_rot, player_id) do
    game
    |> Game.add_combat(player_id, 4)
    |> Game.queue_sacrifice_from_hand_or_discard(player_id)
  end

  def primary_ability(_game, _, _player_id), do: nil

  # Expend abilities

  @spec expend_ability(Game.t(), atom, Player.id(), Card.id()) :: nil | Game.t()
  def expend_ability(game, :cult_priest, player_id, _card_id) do
    game |> Game.queue_interaction(player_id, {:select_effect, [add_gold: 1, add_combat: 1]})
  end

  def expend_ability(game, :death_cultist, player_id, _card_id) do
    game |> Game.add_combat(player_id, 2)
  end

  def expend_ability(game, :rayla, player_id, _card_id) do
    game |> Game.add_combat(player_id, 3)
  end

  def expend_ability(game, :krythos, player_id, _card_id) do
    game
    |> Game.add_combat(player_id, 3)
    |> Game.queue_sacrifice_from_hand_or_discard(player_id, combat_per_card: 3)
  end

  def expend_ability(game, :lys, player_id, _card_id) do
    game
    |> Game.add_combat(player_id, 2)
    |> Game.queue_sacrifice_from_hand_or_discard(player_id, combat_per_card: 2)
  end

  def expend_ability(game, :tyrannor, player_id, _card_id) do
    game
    |> Game.add_combat(player_id, 4)
    |> Game.queue_sacrifice_from_hand_or_discard(player_id, amount: 2)
  end

  def expend_ability(_game, _, _player_id, _card_id), do: nil

  # Ally abilities

  @spec ally_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def ally_ability(game, :cult_priest, player_id) do
    game |> Game.add_combat(player_id, 4)
  end

  def ally_ability(game, :dark_energy, player_id) do
    game |> Game.draw_card(player_id, 1)
  end

  def ally_ability(game, :dark_reward, player_id) do
    game |> Game.add_combat(player_id, 6)
  end

  def ally_ability(game, :death_touch, player_id) do
    game |> Game.add_combat(player_id, 2)
  end

  def ally_ability(game, :rayla, player_id) do
    game |> Game.draw_card(player_id, 1)
  end

  def ally_ability(game, :life_drain, player_id) do
    game |> Game.draw_card(player_id, 1)
  end

  def ally_ability(game, :the_rot, player_id) do
    game |> Game.add_combat(player_id, 3)
  end

  def ally_ability(game, :tyrannor, player_id) do
    game |> Game.draw_card(player_id, 1)
  end

  def ally_ability(_game, _, _player_id), do: nil

  # Sacrifice ability

  @spec sacrifice_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def sacrifice_ability(game, :influence, player_id) do
    game |> Game.add_combat(player_id, 3)
  end

  def sacrifice_ability(_game, _, _player_id), do: nil
end
