defmodule Heros.Cards.Imperial do
  alias Heros.Cards.Card

  @spec get :: list({Card.id(), Card.t()})
  def get do
    Card.with_id(:arkus) ++
      Card.with_id(:close_ranks) ++
      Card.with_id(:command) ++
      Card.with_id(:darian) ++
      Card.with_id(:domination) ++
      Card.with_id(:cristov) ++
      Card.with_id(:kraka) ++
      Card.with_id(:man_at_arms, 2) ++
      Card.with_id(:weyan) ++
      Card.with_id(:rally_troops) ++
      Card.with_id(:recruit, 3) ++
      Card.with_id(:tithe_priest, 2) ++
      Card.with_id(:taxation, 3) ++
      Card.with_id(:word_of_power)
  end
end
