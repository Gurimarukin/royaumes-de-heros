defmodule Heros.Cards.Imperial do
  alias Heros.Cards
  alias Heros.Cards.Card

  @spec get :: list({Card.id(), Card.t()})
  def get do
    Cards.with_id(:arkus) ++
      Cards.with_id(:close_ranks) ++
      Cards.with_id(:command) ++
      Cards.with_id(:darian) ++
      Cards.with_id(:domination) ++
      Cards.with_id(:cristov) ++
      Cards.with_id(:kraka) ++
      Cards.with_id(:man_at_arms, 2) ++
      Cards.with_id(:weyan) ++
      Cards.with_id(:rally_troops) ++
      Cards.with_id(:recruit, 3) ++
      Cards.with_id(:tithe_priest, 2) ++
      Cards.with_id(:taxation, 3) ++
      Cards.with_id(:word_of_power)
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

  @spec champion(atom) :: nil | {:not_guard | :guard, integer}
  def champion(:arkus), do: {:guard, 6}
  def champion(:darian), do: {:not_guard, 5}
  def champion(:cristov), do: {:guard, 5}
  def champion(:kraka), do: {:not_guard, 6}
  def champion(:man_at_arms), do: {:guard, 4}
  def champion(:weyan), do: {:guard, 4}
  def champion(:tithe_priest), do: {:not_guard, 3}
  def champion(_), do: nil
end
