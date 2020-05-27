defmodule Heros.Cards.GuildTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

  test "borg" do
    assert Card.cost(:borg) == 6
    assert Card.type(:borg) == {:guard, 6}
    assert Card.faction(:borg) == :guild
    assert Card.champion?(:borg)
    assert Card.guard?(:borg)

    [borg] = Cards.with_id(:borg)

    {id, card} = borg
    expended_borg = {id, %{card | expend_ability_used: true}}

    p1 = %{Player.empty() | hp: 10, hand: [borg]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(borg, 0))

    p1 = %{p1 | hand: [], fight_zone: [borg]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(borg, 0))

    p1 = %{p1 | combat: 4, fight_zone: [expended_borg]}

    assert Game.player(game, "p1") == p1
  end

  test "bribe" do
    assert Card.cost(:bribe) == 3
    assert Card.type(:bribe) == :action
    assert Card.faction(:bribe) == :guild
    assert not Card.champion?(:bribe)
    assert not Card.guard?(:bribe)

    [bribe] = Cards.with_id(:bribe)
    [rasmus] = Cards.with_id(:rasmus)
    [tithe_priest] = Cards.with_id(:tithe_priest)
    [recruit] = Cards.with_id(:recruit)
    [gem1, gem2] = Cards.with_id(:gem, 2)

    {id, card} = bribe
    expended_bribe = {id, %{card | ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | gold: 10,
        hand: [bribe],
        fight_zone: [rasmus],
        deck: [gem1],
        discard: [gem2]
    }

    p2 = Player.empty()

    game = %{
      Game.empty([{"p1", p1}, {"p2", p2}], "p1")
      | market: [tithe_priest, recruit]
    }

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(bribe, 0))

    p1 = %{p1 | gold: 13, hand: [], fight_zone: [rasmus, bribe]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(bribe, 0))

    p1 = %{
      p1
      | temporary_effects: [:put_next_purchased_action_on_deck],
        fight_zone: [rasmus, expended_bribe]
    }

    assert Game.player(game, "p1") == p1

    # buy champion
    assert {:ok, game} = Game.buy_card(game, "p1", elem(tithe_priest, 0))

    p1 = %{p1 | gold: 11, discard: [tithe_priest, gem2]}

    assert Game.player(game, "p1") == p1
    assert game.market == [nil, recruit]

    before_buy_action = game

    # buy action
    assert {:ok, game} = Game.buy_card(game, "p1", elem(recruit, 0))

    p1 = %{p1 | gold: 9, temporary_effects: [], deck: [recruit, gem1]}

    assert Game.player(game, "p1") == p1
    assert game.market == [nil, nil]

    # discard phase
    game = before_buy_action

    assert {:ok, game} = Game.discard_phase(game, "p1")

    p1 = Game.player(game, "p1")

    assert p1.temporary_effects == []
  end

  test "rasmus" do
    assert Card.cost(:rasmus) == 4
    assert Card.type(:rasmus) == {:not_guard, 5}
    assert Card.faction(:rasmus) == :guild
    assert Card.champion?(:rasmus)
    assert not Card.guard?(:rasmus)
  end
end
