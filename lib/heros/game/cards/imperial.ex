defmodule Heros.Game.Cards.Imperial do
  alias Heros.Game
  alias Heros.Game.{Cards, Player}
  alias Heros.Game.Cards.Card
  alias Heros.Utils.KeyList

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

  @spec cost(atom) :: nil | integer
  def cost(:arkus), do: 8
  def cost(:close_ranks), do: 3
  def cost(:command), do: 5
  def cost(:darian), do: 4
  def cost(:domination), do: 7
  def cost(:cristov), do: 5
  def cost(:kraka), do: 6
  def cost(:man_at_arms), do: 3
  def cost(:weyan), do: 4
  def cost(:rally_troops), do: 4
  def cost(:recruit), do: 2
  def cost(:tithe_priest), do: 2
  def cost(:taxation), do: 1
  def cost(:word_of_power), do: 6
  def cost(_), do: nil

  @spec type(atom) :: nil | :item | :action | {:guard | :not_guard, integer}
  def type(:arkus), do: {:guard, 6}
  def type(:close_ranks), do: :action
  def type(:command), do: :action
  def type(:darian), do: {:not_guard, 5}
  def type(:domination), do: :action
  def type(:cristov), do: {:guard, 5}
  def type(:kraka), do: {:not_guard, 6}
  def type(:man_at_arms), do: {:guard, 4}
  def type(:weyan), do: {:guard, 4}
  def type(:rally_troops), do: :action
  def type(:recruit), do: :action
  def type(:tithe_priest), do: {:not_guard, 3}
  def type(:taxation), do: :action
  def type(:word_of_power), do: :action
  def type(_), do: nil

  @spec faction(atom) :: nil | :imperial
  def faction(:arkus), do: :imperial
  def faction(:close_ranks), do: :imperial
  def faction(:command), do: :imperial
  def faction(:darian), do: :imperial
  def faction(:domination), do: :imperial
  def faction(:cristov), do: :imperial
  def faction(:kraka), do: :imperial
  def faction(:man_at_arms), do: :imperial
  def faction(:weyan), do: :imperial
  def faction(:rally_troops), do: :imperial
  def faction(:recruit), do: :imperial
  def faction(:tithe_priest), do: :imperial
  def faction(:taxation), do: :imperial
  def faction(:word_of_power), do: :imperial
  def faction(_), do: nil

  # Primary ablilities

  @spec primary_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def primary_ability(:close_ranks) do
    fn game, player_id ->
      game
      |> Game.update_player(player_id, fn player ->
        champions = KeyList.count(player.fight_zone, &Card.champion?(&1.key))
        player |> Player.incr_combat(5 + champions * 2)
      end)
    end
  end

  def primary_ability(:command) do
    fn game, player_id ->
      game
      |> Game.add_gold(player_id, 2)
      |> Game.add_combat(player_id, 3)
      |> Game.heal(player_id, 4)
      |> Game.draw_card(player_id, 1)
    end
  end

  def primary_ability(:domination) do
    fn game, player_id ->
      game
      |> Game.add_combat(player_id, 6)
      |> Game.heal(player_id, 6)
      |> Game.draw_card(player_id, 1)
    end
  end

  def primary_ability(:rally_troops) do
    fn game, player_id ->
      game
      |> Game.add_combat(player_id, 5)
      |> Game.heal(player_id, 5)
    end
  end

  def primary_ability(:recruit) do
    fn game, player_id ->
      game
      |> Game.add_gold(player_id, 2)
      |> Game.update_player(player_id, fn player ->
        champions = KeyList.count(player.fight_zone, &Card.champion?(&1.key))
        player |> Player.heal(3 + champions * 1)
      end)
    end
  end

  def primary_ability(:taxation) do
    fn game, player_id -> game |> Game.add_gold(player_id, 2) end
  end

  def primary_ability(:word_of_power) do
    fn game, player_id -> game |> Game.draw_card(player_id, 2) end
  end

  def primary_ability(_), do: nil

  # Expend abilities

  @spec expend_ability(atom) :: nil | (Game.t(), Player.id(), Card.id() -> Game.t())
  def expend_ability(:arkus) do
    fn game, player_id, _card_id ->
      game
      |> Game.add_combat(player_id, 5)
      |> Game.draw_card(player_id, 1)
    end
  end

  def expend_ability(:darian) do
    fn game, player_id, _card_id ->
      game |> Game.queue_select_effect(player_id, add_combat: 3, heal: 4)
    end
  end

  def expend_ability(:cristov) do
    fn game, player_id, _card_id ->
      game
      |> Game.add_combat(player_id, 2)
      |> Game.heal(player_id, 3)
    end
  end

  def expend_ability(:kraka) do
    fn game, player_id, _card_id ->
      game
      |> Game.heal(player_id, 2)
      |> Game.draw_card(player_id, 1)
    end
  end

  def expend_ability(:man_at_arms) do
    fn game, player_id, card_id ->
      game
      |> Game.update_player(player_id, fn player ->
        other_guards =
          Enum.count(player.fight_zone, fn {id, c} -> Card.guard?(c.key) and id != card_id end)

        player |> Player.incr_combat(2 + other_guards * 1)
      end)
    end
  end

  def expend_ability(:weyan) do
    fn game, player_id, card_id ->
      game
      |> Game.update_player(player_id, fn player ->
        other_champions =
          Enum.count(player.fight_zone, fn {id, c} -> Card.champion?(c.key) and id != card_id end)

        player |> Player.incr_combat(3 + other_champions * 1)
      end)
    end
  end

  def expend_ability(:tithe_priest) do
    fn game, player_id, _card_id ->
      game |> Game.queue_select_effect(player_id, add_gold: 1, heal_for_champions: {0, 1})
    end
  end

  def expend_ability(_), do: nil

  # Ally abilities

  @spec ally_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def ally_ability(:arkus) do
    fn game, player_id -> game |> Game.heal(player_id, 6) end
  end

  def ally_ability(:close_ranks) do
    fn game, player_id -> game |> Game.heal(player_id, 6) end
  end

  def ally_ability(:domination) do
    fn game, player_id -> game |> Game.queue_prepare_champion(player_id) end
  end

  def ally_ability(:cristov) do
    fn game, player_id -> game |> Game.draw_card(player_id, 1) end
  end

  def ally_ability(:kraka) do
    fn game, player_id ->
      game
      |> Game.update_player(player_id, fn player ->
        champions = KeyList.count(player.fight_zone, &Card.champion?(&1.key))
        player |> Player.heal(champions * 2)
      end)
    end
  end

  def ally_ability(:rally_troops) do
    fn game, player_id -> game |> Game.queue_prepare_champion(player_id) end
  end

  def ally_ability(:recruit) do
    fn game, player_id -> game |> Game.add_gold(player_id, 1) end
  end

  def ally_ability(:taxation) do
    fn game, player_id -> game |> Game.heal(player_id, 6) end
  end

  def ally_ability(:word_of_power) do
    fn game, player_id -> game |> Game.heal(player_id, 5) end
  end

  def ally_ability(_), do: nil

  # Sacrifice ability

  @spec sacrifice_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def sacrifice_ability(:word_of_power) do
    fn game, player_id -> game |> Game.add_combat(player_id, 5) end
  end

  def sacrifice_ability(_), do: nil
end
