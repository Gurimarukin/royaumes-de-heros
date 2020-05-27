defmodule Heros.Cards.ImperialTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

  test "arkus" do
    assert Card.cost(:arkus) == 8
    assert Card.type(:arkus) == {:guard, 6}
    assert Card.faction(:arkus) == :imperial
    assert Card.champion?(:arkus)
    assert Card.guard?(:arkus)

    [arkus] = Cards.with_id(:arkus)
    [weyan] = Cards.with_id(:weyan)
    [gem1, gem2] = Cards.with_id(:gem, 2)

    {id, arkus_c} = arkus
    expended_arkus = {id, %{arkus_c | expend_ability_used: true, ally_ability_used: false}}
    full_expended_arkus = {id, %{arkus_c | expend_ability_used: true, ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | hp: 10,
        hand: [arkus, weyan],
        deck: [gem1, gem2]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # can't use expend or ally abilities, when card isn't in fight zone
    assert Game.use_expend_ability(game, "p1", elem(arkus, 0)) == :error
    assert Game.use_ally_ability(game, "p1", elem(arkus, 0)) == :error

    assert {:ok, game} = Game.play_card(game, "p1", elem(arkus, 0))

    # can't use ally ability, as there aren't any allies on board
    assert Game.use_ally_ability(game, "p1", elem(arkus, 0)) == :error

    # p2 can't do that
    assert Game.use_expend_ability(game, "p2", elem(arkus, 0)) == :error

    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(arkus, 0))

    p1 = Game.player(game, "p1")

    assert p1.combat == 5
    assert p1.hp == 10
    assert p1.fight_zone == [expended_arkus]
    assert p1.hand == [weyan, gem1]
    assert p1.deck == [gem2]

    # can't use expend ability as it was alredy used
    assert Game.use_expend_ability(game, "p1", elem(arkus, 0)) == :error

    assert {:ok, game} = Game.play_card(game, "p1", elem(weyan, 0))

    assert Game.use_ally_ability(game, "p1", elem(weyan, 0)) == :error

    # p2 can't do that
    assert Game.use_ally_ability(game, "p2", elem(arkus, 0)) == :error

    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(arkus, 0))

    p1 = Game.player(game, "p1")

    assert p1.combat == 5
    assert p1.hp == 16
    assert p1.fight_zone == [full_expended_arkus, weyan]
    assert p1.hand == [gem1]
    assert p1.deck == [gem2]

    # can't use abilities as they were alredy used
    assert Game.use_expend_ability(game, "p1", elem(arkus, 0)) == :error
    assert Game.use_ally_ability(game, "p1", elem(arkus, 0)) == :error
  end

  test "heal" do
    [arkus] = Cards.with_id(:arkus)
    [weyan] = Cards.with_id(:weyan)

    expended_arkus = {elem(arkus, 0), %{elem(arkus, 1) | ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | hp: 48,
        hand: [arkus, weyan]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(weyan, 0))
    assert {:ok, game} = Game.play_card(game, "p1", elem(arkus, 0))
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(arkus, 0))

    p1 = Game.player(game, "p1")

    assert p1.combat == 0
    assert p1.hp == 50
    assert p1.fight_zone == [weyan, expended_arkus]
    assert p1.hand == []
    assert p1.deck == []
  end

  test "close_ranks" do
    assert Card.cost(:close_ranks) == 3
    assert Card.type(:close_ranks) == :action
    assert Card.faction(:close_ranks) == :imperial
    assert not Card.champion?(:action)
    assert not Card.guard?(:action)

    [close_ranks] = Cards.with_id(:close_ranks)
    [arkus] = Cards.with_id(:arkus)
    [rasmus] = Cards.with_id(:rasmus)

    {id, card} = close_ranks
    expended_close_ranks = {id, %{card | ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | hp: 10,
        hand: [arkus, close_ranks, rasmus]
    }

    p2 = Player.empty()

    initial_game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # with 0 champions in play
    game = initial_game
    assert {:ok, game} = Game.play_card(game, "p1", elem(close_ranks, 0))

    assert Game.use_expend_ability(game, "p1", elem(close_ranks, 0)) == :error
    assert Game.use_ally_ability(game, "p1", elem(close_ranks, 0)) == :error

    p1 = Game.player(game, "p1")

    assert p1.fight_zone == [close_ranks]
    assert p1.hand == [arkus, rasmus]
    assert p1.combat == 5
    assert p1.hp == 10

    assert {:ok, game} = Game.play_card(game, "p1", elem(arkus, 0))
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(close_ranks, 0))

    p1 = Game.player(game, "p1")

    assert p1.fight_zone == [expended_close_ranks, arkus]
    assert p1.hand == [rasmus]
    assert p1.combat == 5
    assert p1.hp == 16

    assert {:ok, game} = Game.play_card(game, "p1", elem(rasmus, 0))

    p1 = Game.player(game, "p1")

    assert p1.fight_zone == [expended_close_ranks, arkus, rasmus]
    assert p1.hand == []
    assert p1.combat == 5
    assert p1.hp == 16

    # with 1 champion in play
    game = initial_game

    assert {:ok, game} = Game.play_card(game, "p1", elem(rasmus, 0))
    assert {:ok, game} = Game.play_card(game, "p1", elem(close_ranks, 0))

    p1 = Game.player(game, "p1")

    assert p1.fight_zone == [rasmus, close_ranks]
    assert p1.hand == [arkus]
    assert p1.combat == 7
    assert p1.hp == 10

    # with 2 champions in play
    game = initial_game

    assert {:ok, game} = Game.play_card(game, "p1", elem(arkus, 0))
    assert {:ok, game} = Game.play_card(game, "p1", elem(rasmus, 0))
    assert {:ok, game} = Game.play_card(game, "p1", elem(close_ranks, 0))

    p1 = Game.player(game, "p1")

    assert p1.fight_zone == [arkus, rasmus, close_ranks]
    assert p1.hand == []
    assert p1.combat == 9
    assert p1.hp == 10
  end

  test "command" do
    assert Card.cost(:command) == 5
    assert Card.type(:command) == :action
    assert Card.faction(:command) == :imperial
    assert not Card.champion?(:command)
    assert not Card.guard?(:command)

    [command] = Cards.with_id(:command)
    [gem1, gem2] = Cards.with_id(:gem, 2)

    p1 = %{
      Player.empty()
      | hp: 10,
        hand: [command],
        deck: [gem1, gem2]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(command, 0))

    p1 = Game.player(game, "p1")

    assert p1.gold == 2
    assert p1.combat == 3
    assert p1.hp == 14
    assert p1.fight_zone == [command]
    assert p1.hand == [gem1]
    assert p1.deck == [gem2]
  end

  test "darian" do
    assert Card.cost(:darian) == 4
    assert Card.type(:darian) == {:not_guard, 5}
    assert Card.faction(:darian) == :imperial
    assert Card.champion?(:darian)
    assert not Card.guard?(:darian)

    [darian] = Cards.with_id(:darian)
    [gem1, gem2, gem3] = Cards.with_id(:gem, 3)

    expended_darian = {elem(darian, 0), %{elem(darian, 1) | expend_ability_used: true}}

    p1 = %{
      Player.empty()
      | hp: 10,
        hand: [gem1, darian],
        deck: [gem3, gem2]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(darian, 0))

    p1 = Game.player(game, "p1")

    assert p1.gold == 0
    assert p1.combat == 0
    assert p1.hp == 10
    assert p1.fight_zone == [darian]
    assert p1.hand == [gem1]
    assert p1.deck == [gem3, gem2]
    assert p1.pending_interactions == []

    assert {:ok, before_interaction} = Game.use_expend_ability(game, "p1", elem(darian, 0))

    game = before_interaction

    p1 = Game.player(game, "p1")

    assert p1.fight_zone == [expended_darian]
    assert p1.pending_interactions == [select_effect: [add_combat: 3, heal: 4]]

    # not p2's turn
    assert Game.interact(game, "p2", {:select_effect, 0}) == :error
    # not the pending interaction
    assert Game.interact(game, "p1", {:discard, elem(gem1, 0)}) == :error
    # effect doesn't exist
    assert Game.interact(game, "p1", {:select_effect, 2}) == :error

    # effect 0: combat
    assert {:ok, game} = Game.interact(game, "p1", {:select_effect, 0})

    p1 = Game.player(game, "p1")

    assert p1.gold == 0
    assert p1.combat == 3
    assert p1.hp == 10
    assert p1.fight_zone == [expended_darian]
    assert p1.hand == [gem1]
    assert p1.deck == [gem3, gem2]
    assert p1.pending_interactions == []

    # effect 1: heal
    game = before_interaction

    assert {:ok, game} = Game.interact(game, "p1", {:select_effect, 1})

    p1 = Game.player(game, "p1")

    assert p1.gold == 0
    assert p1.combat == 0
    assert p1.hp == 14
    assert p1.fight_zone == [expended_darian]
    assert p1.hand == [gem1]
    assert p1.deck == [gem3, gem2]
    assert p1.pending_interactions == []
  end

  test "domination" do
    assert Card.cost(:domination) == 7
    assert Card.type(:domination) == :action
    assert Card.faction(:domination) == :imperial
    assert not Card.champion?(:domination)
    assert not Card.guard?(:domination)

    [domination] = Cards.with_id(:domination)
    [arkus] = Cards.with_id(:arkus)
    [weyan] = Cards.with_id(:weyan)
    [gem1, gem2] = Cards.with_id(:gem, 2)

    {id, card} = domination
    expended_domination = {id, %{card | ally_ability_used: true}}

    {id, card} = arkus
    expended_arkus = {id, %{card | expend_ability_used: true}}

    p1 = %{
      Player.empty()
      | hp: 10,
        hand: [domination],
        fight_zone: [expended_arkus, weyan],
        deck: [gem1, gem2]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(domination, 0))

    p1 = %{
      p1
      | combat: 6,
        hp: 16,
        fight_zone: [expended_arkus, weyan, domination],
        hand: [gem1],
        deck: [gem2]
    }

    assert Game.player(game, "p1") == p1

    before_ally = {game, p1}

    # ally (without expended champion)
    game = Game.update_player(game, "p1", &%{&1 | fight_zone: [weyan, domination]})

    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(domination, 0))

    p1 = %{
      p1
      | pending_interactions: [],
        fight_zone: [weyan, expended_domination]
    }

    assert Game.player(game, "p1") == p1

    # ally
    {game, p1} = before_ally

    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(domination, 0))

    p1 = %{
      p1
      | pending_interactions: [prepare_champion: nil],
        fight_zone: [expended_arkus, weyan, expended_domination]
    }

    assert Game.player(game, "p1") == p1

    assert :error = Game.interact(game, "p1", {:prepare_champion, elem(weyan, 0)})
    assert {:ok, game} = Game.interact(game, "p1", {:prepare_champion, elem(arkus, 0)})

    p1 = %{
      p1
      | pending_interactions: [],
        fight_zone: [arkus, weyan, expended_domination]
    }

    assert Game.player(game, "p1") == p1
  end

  test "cristov" do
    assert Card.cost(:cristov) == 5
    assert Card.type(:cristov) == {:guard, 5}
    assert Card.faction(:cristov) == :imperial
    assert Card.champion?(:cristov)
    assert Card.guard?(:cristov)

    [cristov] = Cards.with_id(:cristov)
    [arkus] = Cards.with_id(:arkus)
    [gem] = Cards.with_id(:gem)

    {id, card} = cristov
    expended_cristov = {id, %{card | ally_ability_used: true}}

    {id, card} = expended_cristov
    full_expended_cristov = {id, %{card | expend_ability_used: true}}

    p1 = %{
      Player.empty()
      | combat: 4,
        hp: 10,
        hand: [cristov],
        fight_zone: [arkus],
        discard: [gem]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(cristov, 0))

    p1 = %{p1 | hand: [], fight_zone: [arkus, cristov]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(cristov, 0))

    p1 = %{p1 | hand: [gem], fight_zone: [arkus, expended_cristov], discard: []}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(cristov, 0))

    p1 = %{p1 | combat: 6, hp: 13, fight_zone: [arkus, full_expended_cristov]}

    assert Game.player(game, "p1") == p1
  end

  test "kraka" do
    assert Card.cost(:kraka) == 6
    assert Card.type(:kraka) == {:not_guard, 6}
    assert Card.faction(:kraka) == :imperial
    assert Card.champion?(:kraka)
    assert not Card.guard?(:kraka)

    [kraka] = Cards.with_id(:kraka)
    [arkus] = Cards.with_id(:arkus)
    [rasmus] = Cards.with_id(:rasmus)
    [gem] = Cards.with_id(:gem)

    {id, card} = kraka
    expended_kraka = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_kraka
    full_expended_kraka = {id, %{card | ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | hp: 10,
        hand: [kraka],
        fight_zone: [arkus, rasmus],
        deck: [gem]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(kraka, 0))

    p1 = %{p1 | hand: [], fight_zone: [arkus, rasmus, kraka]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(kraka, 0))

    p1 = %{p1 | hp: 12, hand: [gem], deck: [], fight_zone: [arkus, rasmus, expended_kraka]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(kraka, 0))

    p1 = %{p1 | hp: 18, fight_zone: [arkus, rasmus, full_expended_kraka]}

    assert Game.player(game, "p1") == p1
  end

  test "man_at_arms" do
    assert Card.cost(:man_at_arms) == 3
    assert Card.type(:man_at_arms) == {:guard, 4}
    assert Card.faction(:man_at_arms) == :imperial
    assert Card.champion?(:man_at_arms)
    assert Card.guard?(:man_at_arms)

    [man_at_arms1, man_at_arms2] = Cards.with_id(:man_at_arms, 2)
    [arkus] = Cards.with_id(:arkus)
    [rasmus] = Cards.with_id(:rasmus)
    [gem] = Cards.with_id(:gem)

    {id, card} = man_at_arms1
    expended_man_at_arms1 = {id, %{card | expend_ability_used: true}}

    # with 2 other guards (3 champions) in play
    p1 = %{
      Player.empty()
      | hand: [man_at_arms1],
        fight_zone: [arkus, rasmus, man_at_arms2, gem]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(man_at_arms1, 0))

    p1 = %{p1 | hand: [], fight_zone: [arkus, rasmus, man_at_arms2, gem, man_at_arms1]}

    assert Game.player(game, "p1") == p1

    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(man_at_arms1, 0))

    p1 = %{p1 | combat: 4, fight_zone: [arkus, rasmus, man_at_arms2, gem, expended_man_at_arms1]}

    assert Game.player(game, "p1") == p1

    # with 1 other guard in play
    p1 = %{Player.empty() | fight_zone: [arkus, rasmus, man_at_arms1, gem]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(man_at_arms1, 0))

    p1 = %{p1 | combat: 3, fight_zone: [arkus, rasmus, expended_man_at_arms1, gem]}

    assert Game.player(game, "p1") == p1

    # with no other guard in play
    p1 = %{Player.empty() | fight_zone: [rasmus, man_at_arms1, gem]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(man_at_arms1, 0))

    p1 = %{p1 | combat: 2, fight_zone: [rasmus, expended_man_at_arms1, gem]}

    assert Game.player(game, "p1") == p1
  end

  test "weyan" do
    assert Card.cost(:weyan) == 4
    assert Card.type(:weyan) == {:guard, 4}
    assert Card.faction(:weyan) == :imperial
    assert Card.champion?(:weyan)
    assert Card.guard?(:weyan)

    [weyan] = Cards.with_id(:weyan)
    [arkus] = Cards.with_id(:arkus)
    [rasmus] = Cards.with_id(:rasmus)
    [gem] = Cards.with_id(:gem)

    {id, card} = weyan
    expended_weyan = {id, %{card | expend_ability_used: true}}

    # with 2 other champions in play
    p1 = %{
      Player.empty()
      | hand: [weyan],
        fight_zone: [arkus, rasmus, gem]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(weyan, 0))

    p1 = %{p1 | hand: [], fight_zone: [arkus, rasmus, gem, weyan]}

    assert Game.player(game, "p1") == p1

    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(weyan, 0))

    p1 = %{p1 | combat: 5, fight_zone: [arkus, rasmus, gem, expended_weyan]}

    assert Game.player(game, "p1") == p1

    # with 1 other champion in play
    p1 = %{Player.empty() | fight_zone: [rasmus, weyan, gem]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(weyan, 0))

    p1 = %{p1 | combat: 4, fight_zone: [rasmus, expended_weyan, gem]}

    assert Game.player(game, "p1") == p1

    # with no other champion in play
    p1 = %{Player.empty() | fight_zone: [weyan, gem]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(weyan, 0))

    p1 = %{p1 | combat: 3, fight_zone: [expended_weyan, gem]}

    assert Game.player(game, "p1") == p1
  end

  test "rally_troops" do
    assert Card.cost(:rally_troops) == 4
    assert Card.type(:rally_troops) == :action
    assert Card.faction(:rally_troops) == :imperial
    assert not Card.champion?(:rally_troops)
    assert not Card.guard?(:rally_troops)

    [rally_troops] = Cards.with_id(:rally_troops)
    [arkus] = Cards.with_id(:arkus)

    {id, card} = rally_troops
    expended_rally_troops = {id, %{card | ally_ability_used: true}}

    {id, card} = arkus
    expended_arkus = {id, %{card | expend_ability_used: true}}

    p1 = %{
      Player.empty()
      | hp: 10,
        hand: [rally_troops],
        fight_zone: [expended_arkus]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(rally_troops, 0))

    p1 = %{p1 | combat: 5, hp: 15, hand: [], fight_zone: [expended_arkus, rally_troops]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(rally_troops, 0))

    p1 = %{
      p1
      | pending_interactions: [prepare_champion: nil],
        fight_zone: [expended_arkus, expended_rally_troops]
    }

    assert Game.player(game, "p1") == p1

    assert {:ok, game} = Game.interact(game, "p1", {:prepare_champion, elem(arkus, 0)})

    p1 = %{
      p1
      | pending_interactions: [],
        fight_zone: [arkus, expended_rally_troops]
    }

    assert Game.player(game, "p1") == p1
  end

  test "recruit" do
    assert Card.cost(:recruit) == 2
    assert Card.type(:recruit) == :action
    assert Card.faction(:recruit) == :imperial
    assert not Card.champion?(:recruit)
    assert not Card.guard?(:recruit)

    [recruit] = Cards.with_id(:recruit)
    [arkus] = Cards.with_id(:arkus)
    [gem] = Cards.with_id(:gem)

    {id, card} = recruit
    expended_recruit = {id, %{card | ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | hp: 10,
        hand: [recruit],
        fight_zone: [arkus, gem]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(recruit, 0))

    p1 = %{p1 | gold: 2, hp: 14, hand: [], fight_zone: [arkus, gem, recruit]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(recruit, 0))

    p1 = %{p1 | gold: 3, fight_zone: [arkus, gem, expended_recruit]}

    assert Game.player(game, "p1") == p1
  end

  test "tithe_priest" do
    assert Card.cost(:tithe_priest) == 2
    assert Card.type(:tithe_priest) == {:not_guard, 3}
    assert Card.faction(:tithe_priest) == :imperial
    assert Card.champion?(:tithe_priest)
    assert not Card.guard?(:tithe_priest)

    [tithe_priest] = Cards.with_id(:tithe_priest)
    [arkus] = Cards.with_id(:arkus)
    [rasmus] = Cards.with_id(:rasmus)

    {id, card} = tithe_priest
    expended_tithe_priest = {id, %{card | expend_ability_used: true}}

    p1 = %{
      Player.empty()
      | hp: 10,
        hand: [tithe_priest],
        fight_zone: [arkus, rasmus]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(tithe_priest, 0))

    p1 = %{p1 | hand: [], fight_zone: [arkus, rasmus, tithe_priest]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(tithe_priest, 0))

    p1 = %{
      p1
      | pending_interactions: [
          select_effect: [add_gold: 1, heal_for_champions: {0, 1}]
        ],
        fight_zone: [arkus, rasmus, expended_tithe_priest]
    }

    assert Game.player(game, "p1") == p1

    before_interaction = {game, p1}

    # interaction 0, add gold
    assert {:ok, game} = Game.interact(game, "p1", {:select_effect, 0})

    p1 = %{p1 | gold: 1, pending_interactions: []}

    assert Game.player(game, "p1") == p1

    # interaction 1, heal for champions
    {game, p1} = before_interaction

    assert {:ok, game} = Game.interact(game, "p1", {:select_effect, 1})

    p1 = %{p1 | hp: 13, pending_interactions: []}

    assert Game.player(game, "p1") == p1
  end

  test "taxation" do
    assert Card.cost(:taxation) == 1
    assert Card.type(:taxation) == :action
    assert Card.faction(:taxation) == :imperial
    assert not Card.champion?(:taxation)
    assert not Card.guard?(:taxation)

    [taxation] = Cards.with_id(:taxation)
    [arkus] = Cards.with_id(:arkus)

    {id, card} = taxation
    expended_taxation = {id, %{card | ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | hp: 10,
        hand: [taxation],
        fight_zone: [arkus]
    }

    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(taxation, 0))

    p1 = %{p1 | gold: 2, hand: [], fight_zone: [arkus, taxation]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(taxation, 0))

    p1 = %{p1 | hp: 16, fight_zone: [arkus, expended_taxation]}

    assert Game.player(game, "p1") == p1
  end

  test "word_of_power" do
    assert Card.cost(:word_of_power) == 6
    assert Card.type(:word_of_power) == :action
    assert Card.faction(:word_of_power) == :imperial
    assert not Card.champion?(:word_of_power)
    assert not Card.guard?(:word_of_power)

    [word_of_power] = Cards.with_id(:word_of_power)
    [arkus] = Cards.with_id(:arkus)
    [rasmus] = Cards.with_id(:rasmus)
    [gem1, gem2] = Cards.with_id(:gem, 2)

    {id, card} = word_of_power
    expended_word_of_power = {id, %{card | ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | hp: 10,
        hand: [word_of_power],
        fight_zone: [arkus],
        deck: [gem1],
        discard: [gem2]
    }

    p2 = Player.empty()

    game = %{Game.empty([{"p1", p1}, {"p2", p2}], "p1") | cemetery: [rasmus]}

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(word_of_power, 0))

    p1 = %{
      p1
      | hand: [gem1, gem2],
        fight_zone: [arkus, word_of_power],
        deck: [],
        discard: []
    }

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(word_of_power, 0))

    p1 = %{p1 | hp: 15, fight_zone: [arkus, expended_word_of_power]}

    assert Game.player(game, "p1") == p1

    # sacrifice
    assert {:ok, game} = Game.use_sacrifice_ability(game, "p1", elem(word_of_power, 0))

    p1 = %{p1 | combat: 5, fight_zone: [arkus]}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [word_of_power, rasmus]
  end
end
