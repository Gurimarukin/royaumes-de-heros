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
  def type(:elven_curse), do: :action
  def type(:elven_gift), do: :action
  def type(:grak), do: {:guard, 7}
  def type(:natures_bounty), do: :action
  def type(:orc_grunt), do: {:guard, 3}
  def type(:rampage), do: :action
  def type(:torgen), do: {:guard, 7}
  def type(:spark), do: :action
  def type(:wolf_form), do: :action
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
  def primary_ability(game, :elven_curse, player_id) do
    game
    |> Game.add_combat(player_id, 6)
    |> Game.queue_target_opponent_to_discard(player_id)
  end

  def primary_ability(game, :elven_gift, player_id) do
    game
    |> Game.add_gold(player_id, 2)
    |> Game.queue_draw_then_discard(player_id)
  end

  def primary_ability(game, :natures_bounty, player_id) do
    game |> Game.add_gold(player_id, 4)
  end

  def primary_ability(game, :rampage, player_id) do
    game
    |> Game.add_combat(player_id, 6)
    |> Game.queue_draw_then_discard(player_id, 2)
  end

  def primary_ability(game, :spark, player_id) do
    game
    |> Game.add_combat(player_id, 3)
    |> Game.queue_target_opponent_to_discard(player_id)
  end

  def primary_ability(game, :wolf_form, player_id) do
    game
    |> Game.add_combat(player_id, 8)
    |> Game.queue_target_opponent_to_discard(player_id)
  end

  def primary_ability(_game, _, _player_id), do: nil

  # Expend abilities

  @spec expend_ability(Game.t(), atom, Player.id(), Card.id()) :: nil | Game.t()
  def expend_ability(game, :broelyn, player_id, _card_id) do
    game |> Game.add_gold(player_id, 2)
  end

  def expend_ability(game, :cron, player_id, _card_id) do
    game |> Game.add_combat(player_id, 5)
  end

  def expend_ability(game, :dire_wolf, player_id, _card_id) do
    game |> Game.add_combat(player_id, 3)
  end

  def expend_ability(game, :grak, player_id, _card_id) do
    game
    |> Game.add_combat(player_id, 6)
    |> Game.queue_draw_then_discard(player_id)
  end

  def expend_ability(game, :orc_grunt, player_id, _card_id) do
    game |> Game.add_combat(player_id, 2)
  end

  def expend_ability(game, :torgen, player_id, _card_id) do
    game
    |> Game.add_combat(player_id, 4)
    |> Game.queue_target_opponent_to_discard(player_id)
  end

  def expend_ability(_game, _, _player_id, _card_id), do: nil

  # Ally abilities

  @spec ally_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def ally_ability(game, :broelyn, player_id) do
    game |> Game.queue_target_opponent_to_discard(player_id)
  end

  def ally_ability(game, :cron, player_id) do
    game |> Game.draw_card(player_id, 1)
  end

  def ally_ability(game, :dire_wolf, player_id) do
    game |> Game.add_combat(player_id, 4)
  end

  def ally_ability(game, :elven_curse, player_id) do
    game |> Game.add_combat(player_id, 3)
  end

  def ally_ability(game, :elven_gift, player_id) do
    game |> Game.add_combat(player_id, 4)
  end

  def ally_ability(game, :grak, player_id) do
    game |> Game.queue_draw_then_discard(player_id)
  end

  def ally_ability(game, :natures_bounty, player_id) do
    game |> Game.queue_target_opponent_to_discard(player_id)
  end

  def ally_ability(game, :orc_grunt, player_id) do
    game |> Game.draw_card(player_id, 1)
  end

  def ally_ability(game, :spark, player_id) do
    game |> Game.add_combat(player_id, 2)
  end

  def ally_ability(_game, _, _player_id), do: nil

  # Sacrifice ability

  @spec sacrifice_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def sacrifice_ability(game, :natures_bounty, player_id) do
    game |> Game.add_combat(player_id, 4)
  end

  def sacrifice_ability(game, :wolf_form, player_id) do
    game |> Game.queue_target_opponent_to_discard(player_id)
  end

  def sacrifice_ability(_game, _, _player_id), do: nil
end
