defmodule Heros.Cards.Guild do
  alias Heros.Cards.Card

  @spec get :: list({Card.id(), Card.t()})
  def get do
    Card.with_id(:borg) ++
      Card.with_id(:bribe, 3) ++
      Card.with_id(:death_threat) ++
      Card.with_id(:deception) ++
      Card.with_id(:fire_bomb) ++
      Card.with_id(:hit_job) ++
      Card.with_id(:intimidation, 2) ++
      Card.with_id(:myros) ++
      Card.with_id(:parov) ++
      Card.with_id(:profit, 3) ++
      Card.with_id(:rake) ++
      Card.with_id(:rasmus) ++
      Card.with_id(:smash_and_grab) ++
      Card.with_id(:street_thug, 2)
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
end
