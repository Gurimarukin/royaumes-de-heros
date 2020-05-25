defmodule Heros.Cards.Wild do
  alias Heros.Cards
  alias Heros.Cards.Card

  @spec get :: list({Card.id(), Card.t()})
  def get do
    Cards.with_id(:broelyn) ++
      Cards.with_id(:cron) ++
      Cards.with_id(:dire_wolf) ++
      Cards.with_id(:elven_curse, 2) ++
      Cards.with_id(:elven_gift, 3) ++
      Cards.with_id(:grak) ++
      Cards.with_id(:natures_bounty) ++
      Cards.with_id(:orc_grunt, 2) ++
      Cards.with_id(:rampage) ++
      Cards.with_id(:torgen) ++
      Cards.with_id(:spark, 3) ++
      Cards.with_id(:wolf_form) ++
      Cards.with_id(:wolf_shaman, 2)
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

  @spec champion(atom) :: nil | {:not_guard | :guard, integer}
  def champion(:broelyn), do: {:not_guard, 6}
  def champion(:cron), do: {:not_guard, 6}
  def champion(:dire_wolf), do: {:guard, 5}
  def champion(:grak), do: {:guard, 7}
  def champion(:orc_grunt), do: {:guard, 3}
  def champion(:torgen), do: {:guard, 7}
  def champion(:wolf_shaman), do: {:not_guard, 4}
  def champion(_), do: nil
end
