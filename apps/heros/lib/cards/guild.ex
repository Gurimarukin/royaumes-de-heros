defmodule Heros.Cards.Guild do
  alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

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
  def type(:myros), do: {:guard, 3}
  def type(:parov), do: {:guard, 5}
  def type(:rake), do: {:not_guard, 7}
  def type(:rasmus), do: {:not_guard, 5}
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

  @spec primary_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def primary_ability(_game, _, _player_id), do: nil

  # Expend abilities

  @spec expend_ability(Game.t(), atom, Player.id(), Card.id()) :: nil | Game.t()
  def expend_ability(game, :borg, player_id, _card_id) do
    game |> Game.add_combat(player_id, 4)
  end

  def expend_ability(_game, _, _player_id, _card_id), do: nil

  # Ally abilities

  @spec ally_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def ally_ability(_game, _, _player_id), do: nil

  # Sacrifice ability

  @spec sacrifice_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def sacrifice_ability(_game, _, _player_id), do: nil
end
