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

  @spec price(atom) :: nil | integer
  def price(:arkus), do: 8
  def price(:close_ranks), do: 3
  def price(:command), do: 5
  def price(:darian), do: 4
  def price(:domination), do: 7
  def price(:cristov), do: 5
  def price(:kraka), do: 6
  def price(:man_at_arms), do: 3
  def price(:weyan), do: 4
  def price(:rally_troops), do: 4
  def price(:recruit), do: 2
  def price(:tithe_priest), do: 2
  def price(:taxation), do: 1
  def price(:word_of_power), do: 6
  def price(_), do: nil
end
