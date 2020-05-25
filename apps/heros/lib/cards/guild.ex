defmodule Heros.Cards.Guild do
  alias Heros.Cards
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

  @spec price(atom) :: nil | integer
  def price(:borg), do: 6
  def price(:bribe), do: 3
  def price(:death_threat), do: 3
  def price(:deception), do: 5
  def price(:fire_bomb), do: 8
  def price(:hit_job), do: 4
  def price(:intimidation), do: 2
  def price(:myros), do: 5
  def price(:parov), do: 5
  def price(:profit), do: 1
  def price(:rake), do: 7
  def price(:rasmus), do: 4
  def price(:smash_and_grab), do: 6
  def price(:street_thug), do: 3
  def price(_), do: nil

  @spec champion(atom) :: nil | {:not_guard | :guard, integer}
  def champion(:borg), do: {:guard, 6}
  def champion(:myros), do: {:guard, 3}
  def champion(:parov), do: {:guard, 5}
  def champion(:rake), do: {:not_guard, 7}
  def champion(:rasmus), do: {:not_guard, 5}
  def champion(:street_thug), do: {:not_guard, 4}
  def champion(_), do: nil
end
