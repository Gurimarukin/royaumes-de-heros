defmodule Heros.Cards.Wild do
  alias Heros.{Cards, Game, Player}
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

  @spec cost(atom) :: nil | integer
  def cost(:broelyn), do: 4
  def cost(:cron), do: 6
  def cost(:dire_wolf), do: 5
  def cost(:elven_curse), do: 3
  def cost(:elven_gift), do: 2
  def cost(:grak), do: 8
  def cost(:natures_bounty), do: 4
  def cost(:orc_grunt), do: 3
  def cost(:rampage), do: 6
  def cost(:torgen), do: 7
  def cost(:spark), do: 1
  def cost(:wolf_form), do: 5
  def cost(:wolf_shaman), do: 2
  def cost(_), do: nil

  @spec type(atom) :: nil | :item | :action | {:guard | :not_guard, integer}
  def type(:broelyn), do: {:not_guard, 6}
  def type(:cron), do: {:not_guard, 6}
  def type(:dire_wolf), do: {:guard, 5}
  def type(:grak), do: {:guard, 7}
  def type(:orc_grunt), do: {:guard, 3}
  def type(:torgen), do: {:guard, 7}
  def type(:wolf_shaman), do: {:not_guard, 4}
  def type(_), do: nil

  @spec faction(atom) :: nil | :wild
  def faction(:broelyn), do: :wild
  def faction(:cron), do: :wild
  def faction(:dire_wolf), do: :wild
  def faction(:elven_curse), do: :wild
  def faction(:elven_gift), do: :wild
  def faction(:grak), do: :wild
  def faction(:natures_bounty), do: :wild
  def faction(:orc_grunt), do: :wild
  def faction(:rampage), do: :wild
  def faction(:torgen), do: :wild
  def faction(:spark), do: :wild
  def faction(:wolf_form), do: :wild
  def faction(:wolf_shaman), do: :wild
  def faction(_), do: nil

  # Primary ablilities

  @spec primary_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def primary_ability(_game, _, _player_id), do: nil

  # Expend abilities

  @spec expend_ability(Game.t(), atom, Player.id(), Card.id()) :: nil | Game.t()
  def expend_ability(_game, _, _player_id, _card_id), do: nil

  # Ally abilities

  @spec ally_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def ally_ability(_game, _, _player_id), do: nil

  # Sacrifice ability

  @spec sacrifice_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def sacrifice_ability(_game, _, _player_id), do: nil
end
