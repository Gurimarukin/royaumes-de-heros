defmodule Heros.Cards.Imperial do
  alias Heros.{Cards, Game, KeyListUtils, Player}
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

  @spec primary_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def primary_ability(game, :close_ranks, player_id) do
    game
    |> Game.update_player(player_id, fn player ->
      champions = KeyListUtils.count(player.fight_zone, &Card.champion?(&1.key))
      player |> Player.incr_combat(5 + champions * 2)
    end)
  end

  def primary_ability(game, :command, player_id) do
    game
    |> Game.add_gold(player_id, 2)
    |> Game.add_combat(player_id, 3)
    |> Game.heal(player_id, 4)
    |> Game.draw_card(player_id, 1)
  end

  def primary_ability(game, :domination, player_id) do
    game
    |> Game.add_combat(player_id, 6)
    |> Game.heal(player_id, 6)
    |> Game.draw_card(player_id, 1)
  end

  def primary_ability(game, :rally_troops, player_id) do
    game
    |> Game.add_combat(player_id, 5)
    |> Game.heal(player_id, 5)
  end

  def primary_ability(game, :recruit, player_id) do
    game
    |> Game.add_gold(player_id, 2)
    |> Game.update_player(player_id, fn player ->
      champions = KeyListUtils.count(player.fight_zone, &Card.champion?(&1.key))
      player |> Player.heal(3 + champions * 1)
    end)
  end

  def primary_ability(game, :taxation, player_id) do
    game |> Game.add_gold(player_id, 2)
  end

  def primary_ability(_game, _, _player_id), do: nil

  # Expend abilities

  @spec expend_ability(Game.t(), atom, Player.id(), Card.id()) :: nil | Game.t()
  def expend_ability(game, :arkus, player_id, _card_id) do
    game
    |> Game.add_combat(player_id, 5)
    |> Game.draw_card(player_id, 1)
  end

  def expend_ability(game, :darian, player_id, _card_id) do
    game |> Game.queue_interaction(player_id, {:select_effect, [add_combat: 3, heal: 4]})
  end

  def expend_ability(game, :cristov, player_id, _card_id) do
    game
    |> Game.add_combat(player_id, 2)
    |> Game.heal(player_id, 3)
  end

  def expend_ability(game, :kraka, player_id, _card_id) do
    game
    |> Game.heal(player_id, 2)
    |> Game.draw_card(player_id, 1)
  end

  def expend_ability(game, :man_at_arms, player_id, card_id) do
    game
    |> Game.update_player(player_id, fn player ->
      other_guards =
        Enum.count(player.fight_zone, fn {id, c} -> Card.guard?(c.key) and id != card_id end)

      player |> Player.incr_combat(2 + other_guards * 1)
    end)
  end

  def expend_ability(game, :weyan, player_id, card_id) do
    game
    |> Game.update_player(player_id, fn player ->
      other_champions =
        Enum.count(player.fight_zone, fn {id, c} -> Card.champion?(c.key) and id != card_id end)

      player |> Player.incr_combat(3 + other_champions * 1)
    end)
  end

  def expend_ability(game, :tithe_priest, player_id, _card_id) do
    game
    |> Game.queue_interaction(
      player_id,
      {:select_effect, [add_gold: 1, heal_for_champions: {0, 1}]}
    )
  end

  def expend_ability(_game, _, _player_id, _card_id), do: nil

  # Ally abilities

  @spec ally_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def ally_ability(game, :arkus, player_id) do
    game |> Game.heal(player_id, 6)
  end

  def ally_ability(game, :close_ranks, player_id) do
    game |> Game.heal(player_id, 6)
  end

  def ally_ability(game, :domination, player_id) do
    game |> Game.queue_prepare_champion(player_id)
  end

  def ally_ability(game, :cristov, player_id) do
    game |> Game.draw_card(player_id, 1)
  end

  def ally_ability(game, :kraka, player_id) do
    game
    |> Game.update_player(player_id, fn player ->
      champions = KeyListUtils.count(player.fight_zone, &Card.champion?(&1.key))
      player |> Player.heal(champions * 2)
    end)
  end

  def ally_ability(game, :rally_troops, player_id) do
    game |> Game.queue_prepare_champion(player_id)
  end

  def ally_ability(game, :recruit, player_id) do
    game |> Game.add_gold(player_id, 1)
  end
  
  def ally_ability(game, :taxation, player_id) do
    game |> Game.heal(player_id, 6)
  end

  def ally_ability(_game, _, _player_id), do: nil
end
