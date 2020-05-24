defmodule Heros.Cards.Wild do
  alias Heros.Cards.Card

  @spec get :: list({Card.id(), Card.t()})
  def get do
    Card.with_id(:broelyn) ++
      Card.with_id(:cron) ++
      Card.with_id(:dire_wolf) ++
      Card.with_id(:elven_curse, 2) ++
      Card.with_id(:elven_gift, 3) ++
      Card.with_id(:grak) ++
      Card.with_id(:natures_bounty) ++
      Card.with_id(:orc_grunt, 2) ++
      Card.with_id(:rampage) ++
      Card.with_id(:torgen) ++
      Card.with_id(:spark, 3) ++
      Card.with_id(:wolf_form) ++
      Card.with_id(:wolf_shaman, 2)
  end

  @spec price(atom) :: nil | integer
  def price(:broelyn), do: 4
  def price(:cron), do: 6
  def price(:dire_wolf), do: 5
  def price(:elven_curse), do: 3
  def price(:elven_gift), do: 2
  def price(:grak), do: 8
  def price(:natures_bounty), do: 4
  def price(:orc_grunt), do: 3
  def price(:rampage), do: 6
  def price(:torgen), do: 7
  def price(:spark), do: 1
  def price(:wolf_form), do: 5
  def price(:wolf_shaman), do: 2
  def price(_), do: nil
end
