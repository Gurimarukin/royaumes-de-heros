defmodule Heros.Cards.ImperialTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

  test "arkus" do
    assert Card.cost(:arkus) == 8
    assert Card.type(:arkus) == {:guard, 6}
    assert Card.faction(:arkus) == :imperial
    assert Card.is_champion(:arkus)
    assert Card.is_guard(:arkus)

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
    assert not Card.is_champion(:action)
    assert not Card.is_guard(:action)

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
    assert not Card.is_champion(:command)
    assert not Card.is_guard(:command)

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
    assert Card.is_champion(:darian)
    assert not Card.is_guard(:darian)

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
    assert Game.perform_interaction(game, "p2", {:select_effect, 0}) == :error
    # not the pending interaction
    assert Game.perform_interaction(game, "p1", {:discard, elem(gem1, 0)}) == :error
    # effect doesn't exist
    assert Game.perform_interaction(game, "p1", {:select_effect, 2}) == :error

    # effect 0: combat
    assert {:ok, game} = Game.perform_interaction(game, "p1", {:select_effect, 0})

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

    assert {:ok, game} = Game.perform_interaction(game, "p1", {:select_effect, 1})

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
    assert not Card.is_champion(:domination)
    assert not Card.is_guard(:domination)

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

    assert :error = Game.perform_interaction(game, "p1", {:prepare_champion, elem(weyan, 0)})
    assert {:ok, game} = Game.perform_interaction(game, "p1", {:prepare_champion, elem(arkus, 0)})

    p1 = %{
      p1
      | pending_interactions: [],
        fight_zone: [arkus, weyan, expended_domination]
    }

    assert Game.player(game, "p1") == p1
  end
end
