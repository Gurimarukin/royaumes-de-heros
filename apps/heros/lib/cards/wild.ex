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
      Card.with_id(:wolfs_shaman, 2)
  end
end
