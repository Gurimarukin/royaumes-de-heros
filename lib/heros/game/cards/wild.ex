defmodule Heros.Game.Cards.Wild do
  alias Heros.Game
  alias Heros.Game.{Cards, Player}
  alias Heros.Game.Cards.Card

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

  @spec primary_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def primary_ability(:elven_curse) do
    fn game, player_id ->
      game
      |> Game.add_combat(player_id, 6)
      |> Game.queue_target_opponent_to_discard(player_id)
    end
  end

  def primary_ability(:elven_gift) do
    fn game, player_id ->
      game
      |> Game.add_gold(player_id, 2)
      |> Game.queue_draw_then_discard(player_id)
    end
  end

  def primary_ability(:natures_bounty) do
    fn game, player_id -> game |> Game.add_gold(player_id, 4) end
  end

  def primary_ability(:rampage) do
    fn game, player_id ->
      game
      |> Game.add_combat(player_id, 6)
      |> Game.queue_draw_then_discard(player_id, 2)
    end
  end

  def primary_ability(:spark) do
    fn game, player_id ->
      game
      |> Game.add_combat(player_id, 3)
      |> Game.queue_target_opponent_to_discard(player_id)
    end
  end

  def primary_ability(:wolf_form) do
    fn game, player_id ->
      game
      |> Game.add_combat(player_id, 8)
      |> Game.queue_target_opponent_to_discard(player_id)
    end
  end

  def primary_ability(_), do: nil

  # Expend abilities

  @spec expend_ability(atom) :: nil | (Game.t(), Player.id(), Card.id() -> Game.t())
  def expend_ability(:broelyn) do
    fn game, player_id, _card_id -> game |> Game.add_gold(player_id, 2) end
  end

  def expend_ability(:cron) do
    fn game, player_id, _card_id -> game |> Game.add_combat(player_id, 5) end
  end

  def expend_ability(:dire_wolf) do
    fn game, player_id, _card_id -> game |> Game.add_combat(player_id, 3) end
  end

  def expend_ability(:grak) do
    fn game, player_id, _card_id ->
      game
      |> Game.add_combat(player_id, 6)
      |> Game.queue_draw_then_discard(player_id)
    end
  end

  def expend_ability(:orc_grunt) do
    fn game, player_id, _card_id -> game |> Game.add_combat(player_id, 2) end
  end

  def expend_ability(:torgen) do
    fn game, player_id, _card_id ->
      game
      |> Game.add_combat(player_id, 4)
      |> Game.queue_target_opponent_to_discard(player_id)
    end
  end

  def expend_ability(:wolf_shaman) do
    fn game, player_id, card_id ->
      game
      |> Game.update_player(player_id, fn player ->
        other_wilds =
          Enum.count(player.fight_zone, fn {id, c} ->
            Card.faction(c.key) == :wild and id != card_id
          end)

        player |> Player.incr_combat(2 + other_wilds * 1)
      end)
    end
  end

  def expend_ability(_), do: nil

  # Ally abilities

  @spec ally_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def ally_ability(:broelyn) do
    fn game, player_id -> game |> Game.queue_target_opponent_to_discard(player_id) end
  end

  def ally_ability(:cron) do
    fn game, player_id -> game |> Game.draw_card(player_id, 1) end
  end

  def ally_ability(:dire_wolf) do
    fn game, player_id -> game |> Game.add_combat(player_id, 4) end
  end

  def ally_ability(:elven_curse) do
    fn game, player_id -> game |> Game.add_combat(player_id, 3) end
  end

  def ally_ability(:elven_gift) do
    fn game, player_id -> game |> Game.add_combat(player_id, 4) end
  end

  def ally_ability(:grak) do
    fn game, player_id -> game |> Game.queue_draw_then_discard(player_id) end
  end

  def ally_ability(:natures_bounty) do
    fn game, player_id -> game |> Game.queue_target_opponent_to_discard(player_id) end
  end

  def ally_ability(:orc_grunt) do
    fn game, player_id -> game |> Game.draw_card(player_id, 1) end
  end

  def ally_ability(:spark) do
    fn game, player_id -> game |> Game.add_combat(player_id, 2) end
  end

  def ally_ability(_), do: nil

  # Sacrifice ability

  @spec sacrifice_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def sacrifice_ability(:natures_bounty) do
    fn game, player_id -> game |> Game.add_combat(player_id, 4) end
  end

  def sacrifice_ability(:wolf_form) do
    fn game, player_id -> game |> Game.queue_target_opponent_to_discard(player_id) end
  end

  def sacrifice_ability(_), do: nil
end
