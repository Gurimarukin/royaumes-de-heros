defmodule Heros.Cards.Necros do
  alias Heros.Cards.Card

  @spec get :: list({Card.id(), Card.t()})
  def get do
    Card.with_id(:cult_priest, 2) ++
      Card.with_id(:dark_energy) ++
      Card.with_id(:dark_reward) ++
      Card.with_id(:death_cultist, 2) ++
      Card.with_id(:death_touch, 3) ++
      Card.with_id(:rayla) ++
      Card.with_id(:influence, 3) ++
      Card.with_id(:krythos) ++
      Card.with_id(:life_drain) ++
      Card.with_id(:lys) ++
      Card.with_id(:the_rot, 2) ++
      Card.with_id(:tyrannor) ++
      Card.with_id(:varrick)
  end

  @spec price(atom) :: nil | integer
  def price(:cult_priest), do: 3
  def price(:dark_energy), do: 4
  def price(:dark_reward), do: 5
  def price(:death_cultist), do: 2
  def price(:death_touch), do: 1
  def price(:rayla), do: 4
  def price(:influence), do: 2
  def price(:krythos), do: 7
  def price(:life_drain), do: 6
  def price(:lys), do: 6
  def price(:the_rot), do: 3
  def price(:tyrannor), do: 8
  def price(:varrick), do: 5
  def price(_), do: nil
end
