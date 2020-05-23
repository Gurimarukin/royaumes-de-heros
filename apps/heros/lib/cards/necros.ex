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
end
