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
end
