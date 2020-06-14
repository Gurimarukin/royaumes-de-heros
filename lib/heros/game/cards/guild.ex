defmodule Heros.Game.Cards.Guild do
  alias Heros.Game
  alias Heros.Game.{Cards, Player}
  alias Heros.Game.Cards.Card

  @spec get :: list({Card.id(), Card.t()})
  def get do
    Cards.with_id(:borg) ++
      Cards.with_id(:bribe, 3) ++
      Cards.with_id(:death_threat) ++
      Cards.with_id(:deception) ++
      Cards.with_id(:fire_bomb) ++
      Cards.with_id(:hit_job) ++
      Cards.with_id(:intimidation, 2) ++
      Cards.with_id(:myros) ++
      Cards.with_id(:parov) ++
      Cards.with_id(:profit, 3) ++
      Cards.with_id(:rake) ++
      Cards.with_id(:rasmus) ++
      Cards.with_id(:smash_and_grab) ++
      Cards.with_id(:street_thug, 2)
  end

  @spec cost(atom) :: nil | integer
  def cost(:borg), do: 6
  def cost(:bribe), do: 3
  def cost(:death_threat), do: 3
  def cost(:deception), do: 5
  def cost(:fire_bomb), do: 8
  def cost(:hit_job), do: 4
  def cost(:intimidation), do: 2
  def cost(:myros), do: 5
  def cost(:parov), do: 5
  def cost(:profit), do: 1
  def cost(:rake), do: 7
  def cost(:rasmus), do: 4
  def cost(:smash_and_grab), do: 6
  def cost(:street_thug), do: 3
  def cost(_), do: nil

  @spec type(atom) :: nil | :item | :action | {:guard | :not_guard, integer}
  def type(:borg), do: {:guard, 6}
  def type(:bribe), do: :action
  def type(:death_threat), do: :action
  def type(:deception), do: :action
  def type(:fire_bomb), do: :action
  def type(:hit_job), do: :action
  def type(:intimidation), do: :action
  def type(:myros), do: {:guard, 3}
  def type(:parov), do: {:guard, 5}
  def type(:profit), do: :action
  def type(:rake), do: {:not_guard, 7}
  def type(:rasmus), do: {:not_guard, 5}
  def type(:smash_and_grab), do: :action
  def type(:street_thug), do: {:not_guard, 4}
  def type(_), do: nil

  @spec faction(atom) :: nil | :guild
  def faction(:borg), do: :guild
  def faction(:bribe), do: :guild
  def faction(:death_threat), do: :guild
  def faction(:deception), do: :guild
  def faction(:fire_bomb), do: :guild
  def faction(:hit_job), do: :guild
  def faction(:intimidation), do: :guild
  def faction(:myros), do: :guild
  def faction(:parov), do: :guild
  def faction(:profit), do: :guild
  def faction(:rake), do: :guild
  def faction(:rasmus), do: :guild
  def faction(:smash_and_grab), do: :guild
  def faction(:street_thug), do: :guild
  def faction(_), do: nil

  # Primary ablilities

  @spec primary_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def primary_ability(:bribe) do
    fn game, player_id ->
      game |> Game.add_gold(player_id, 3)
    end
  end

  def primary_ability(:deception) do
    fn game, player_id ->
      game
      |> Game.add_gold(player_id, 2)
      |> Game.draw_card(player_id, 1)
    end
  end

  def primary_ability(:fire_bomb) do
    fn game, player_id ->
      game
      |> Game.add_combat(player_id, 8)
      |> Game.queue_stun_champion(player_id)
      |> Game.draw_card(player_id, 1)
    end
  end

  def primary_ability(:hit_job) do
    fn game, player_id ->
      game |> Game.add_combat(player_id, 7)
    end
  end

  def primary_ability(:intimidation) do
    fn game, player_id -> game |> Game.add_combat(player_id, 5) end
  end

  def primary_ability(:profit) do
    fn game, player_id -> game |> Game.add_gold(player_id, 2) end
  end

  def primary_ability(:smash_and_grab) do
    fn game, player_id ->
      game
      |> Game.add_combat(player_id, 6)
      |> Game.queue_put_card_from_discard_to_deck(player_id)
    end
  end

  def primary_ability(_), do: nil

  # Expend abilities

  @spec expend_ability(atom) :: nil | (Game.t(), Player.id(), Card.id() -> Game.t())
  def expend_ability(:borg) do
    fn game, player_id, _card_id -> game |> Game.add_combat(player_id, 4) end
  end

  def expend_ability(:myros) do
    fn game, player_id, _card_id -> game |> Game.add_gold(player_id, 3) end
  end

  def expend_ability(:parov) do
    fn game, player_id, _card_id -> game |> Game.add_combat(player_id, 3) end
  end

  def expend_ability(:rake) do
    fn game, player_id, _card_id ->
      game
      |> Game.add_combat(player_id, 4)
      |> Game.queue_stun_champion(player_id)
    end
  end

  def expend_ability(:rasmus) do
    fn game, player_id, _card_id -> game |> Game.add_gold(player_id, 2) end
  end

  def expend_ability(:street_thug) do
    fn game, player_id, _card_id ->
      game |> Game.queue_select_effect(player_id, add_gold: 1, add_combat: 2)
    end
  end

  def expend_ability(_), do: nil

  # Ally abilities

  @spec ally_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def ally_ability(:bribe) do
    fn game, player_id ->
      game |> Game.add_temporary_effect(player_id, :put_next_purchased_action_on_deck)
    end
  end

  def ally_ability(:death_threat) do
    fn game, player_id -> game |> Game.queue_stun_champion(player_id) end
  end

  def ally_ability(:deception) do
    fn game, player_id ->
      game |> Game.add_temporary_effect(player_id, :put_next_purchased_card_in_hand)
    end
  end

  def ally_ability(:hit_job) do
    fn game, player_id -> game |> Game.queue_stun_champion(player_id) end
  end

  def ally_ability(:intimidation) do
    fn game, player_id -> game |> Game.add_gold(player_id, 2) end
  end

  def ally_ability(:myros) do
    fn game, player_id -> game |> Game.add_combat(player_id, 4) end
  end

  def ally_ability(:parov) do
    fn game, player_id -> game |> Game.draw_card(player_id, 1) end
  end

  def ally_ability(:profit) do
    fn game, player_id -> game |> Game.add_combat(player_id, 4) end
  end

  def ally_ability(:rasmus) do
    fn game, player_id ->
      game |> Game.add_temporary_effect(player_id, :put_next_purchased_card_on_deck)
    end
  end

  def ally_ability(_), do: nil

  # Sacrifice ability

  @spec sacrifice_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def sacrifice_ability(:fire_bomb) do
    fn game, player_id -> game |> Game.add_combat(player_id, 5) end
  end

  def sacrifice_ability(_), do: nil
end
