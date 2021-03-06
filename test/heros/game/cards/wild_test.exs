defmodule Heros.Game.Cards.WildTest do
  use ExUnit.Case, async: true

  alias Heros.Game
  alias Heros.Game.{Cards, Player}
  alias Heros.Game.Cards.Card

  test "broelyn" do
    assert Card.cost(:broelyn) == 4
    assert Card.type(:broelyn) == {:not_guard, 6}
    assert Card.faction(:broelyn) == :wild
    assert Card.champion?(:broelyn)
    assert not Card.guard?(:broelyn)

    [broelyn] = Cards.with_id(:broelyn)
    [cron] = Cards.with_id(:cron)
    [gem1, gem2] = Cards.with_id(:gem, 2)

    {id, card} = broelyn
    expended_broelyn = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_broelyn
    full_expended_broelyn = {id, %{card | ally_ability_used: true}}

    # p2 has a card in hand

    p1 = %{Player.empty() | hand: [broelyn], fight_zone: [cron]}
    p2 = %{Player.empty() | hand: [gem1, gem2]}
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(broelyn, 0))

    p1 = %{p1 | hand: [], fight_zone: [cron, broelyn]}

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(broelyn, 0))

    p1 = %{p1 | fight_zone: [cron, expended_broelyn], gold: 2}

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(broelyn, 0))

    p1 = %{
      p1
      | fight_zone: [cron, full_expended_broelyn],
        pending_interactions: [:target_opponent_to_discard]
    }

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2

    before_p1_interact = {game, p1, p2}

    # p1 interact
    assert :error = Game.interact(game, "p1", {:target_opponent_to_discard, "p3"})
    assert {:ok, game} = Game.interact(game, "p1", {:target_opponent_to_discard, "p2"})

    p1 = %{p1 | pending_interactions: []}
    p2 = %{p2 | pending_interactions: [:discard_card]}

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2

    before_p2_interact = {game, p1, p2}

    # p1 doesn't interact
    {game, p1, p2} = before_p1_interact

    assert {:ok, game} = Game.interact(game, "p1", {:target_opponent_to_discard, nil})

    p1 = %{p1 | pending_interactions: []}

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2

    # p2 interact during p1's turn
    {game, p1, p2} = before_p2_interact

    assert :error = Game.interact(game, "p2", {:discard_card, nil})
    assert :error = Game.interact(game, "p2", {:discard_card, elem(broelyn, 0)})
    assert {:ok, game} = Game.interact(game, "p2", {:discard_card, elem(gem1, 0)})

    p2 = %{p2 | pending_interactions: [], hand: [gem2], discard: [gem1]}

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2

    # p2 didn't interact until his turn
    {game, p1, p2} = before_p2_interact

    assert {:ok, game} = Game.discard_phase(game, "p1")
    assert {:ok, game} = Game.draw_phase(game, "p1")
    assert game.current_player == "p2"

    # p2 can't play as he didn't discard
    assert :error = Game.play_card(game, "p2", gem2)
    assert {:ok, game} = Game.interact(game, "p2", {:discard_card, elem(gem1, 0)})

    p1 = %{p1 | gold: 0, fight_zone: [cron, broelyn]}
    p2 = %{p2 | pending_interactions: [], hand: [gem2], discard: [gem1]}

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2

    assert {:ok, game} = Game.play_card(game, "p2", elem(gem2, 0))

    # no other player has card in hand

    p1 = %{Player.empty() | hand: [broelyn], fight_zone: [cron]}
    p2 = Player.empty()
    p3 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}, {"p3", p3}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(broelyn, 0))

    p1 = %{p1 | hand: [], fight_zone: [cron, broelyn]}

    assert Game.player(game, "p1") == p1

    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(broelyn, 0))

    p1 = %{
      p1
      | fight_zone: [
          cron,
          {elem(broelyn, 0), %{elem(broelyn, 1) | ally_ability_used: true}}
        ]
    }

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2
    assert Game.player(game, "p3") == p3
  end

  test "cron" do
    assert Card.cost(:cron) == 6
    assert Card.type(:cron) == {:not_guard, 6}
    assert Card.faction(:cron) == :wild
    assert Card.champion?(:cron)
    assert not Card.guard?(:cron)

    [cron] = Cards.with_id(:cron)
    [broelyn] = Cards.with_id(:broelyn)
    [gem] = Cards.with_id(:gem)

    {id, card} = cron
    expended_cron = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_cron
    full_expended_cron = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [cron], fight_zone: [broelyn], discard: [gem]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(cron, 0))

    p1 = %{p1 | hand: [], fight_zone: [broelyn, cron]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(cron, 0))

    p1 = %{p1 | fight_zone: [broelyn, expended_cron], combat: 5}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(cron, 0))

    p1 = %{p1 | fight_zone: [broelyn, full_expended_cron], hand: [gem], discard: []}

    assert Game.player(game, "p1") == p1
  end

  test "dire_wolf" do
    assert Card.cost(:dire_wolf) == 5
    assert Card.type(:dire_wolf) == {:guard, 5}
    assert Card.faction(:dire_wolf) == :wild
    assert Card.champion?(:dire_wolf)
    assert Card.guard?(:dire_wolf)

    [dire_wolf] = Cards.with_id(:dire_wolf)
    [cron] = Cards.with_id(:cron)

    {id, card} = dire_wolf
    expended_dire_wolf = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_dire_wolf
    full_expended_dire_wolf = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [dire_wolf], fight_zone: [cron]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(dire_wolf, 0))

    p1 = %{p1 | hand: [], fight_zone: [cron, dire_wolf]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(dire_wolf, 0))

    p1 = %{p1 | fight_zone: [cron, expended_dire_wolf], combat: 3}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(dire_wolf, 0))

    p1 = %{p1 | fight_zone: [cron, full_expended_dire_wolf], combat: 7}

    assert Game.player(game, "p1") == p1
  end

  test "elven_curse" do
    assert Card.cost(:elven_curse) == 3
    assert Card.type(:elven_curse) == :action
    assert Card.faction(:elven_curse) == :wild
    assert not Card.champion?(:elven_curse)
    assert not Card.guard?(:elven_curse)

    [elven_curse] = Cards.with_id(:elven_curse)
    [cron] = Cards.with_id(:cron)
    [gem] = Cards.with_id(:gem)

    {id, card} = elven_curse
    expended_elven_curse = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [elven_curse], fight_zone: [cron]}
    p2 = %{Player.empty() | hand: [gem]}
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(elven_curse, 0))

    p1 = %{
      p1
      | hand: [],
        fight_zone: [cron, elven_curse],
        combat: 6,
        pending_interactions: [:target_opponent_to_discard]
    }

    assert Game.player(game, "p1") == p1

    # interact
    assert {:ok, game} = Game.interact(game, "p1", {:target_opponent_to_discard, "p2"})

    p1 = %{p1 | pending_interactions: []}
    p2 = %{p2 | pending_interactions: [:discard_card]}

    assert Game.player(game, "p2") == p2

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(elven_curse, 0))

    p1 = %{p1 | fight_zone: [cron, expended_elven_curse], combat: 9}

    assert Game.player(game, "p1") == p1
  end

  test "elven_gift" do
    assert Card.cost(:elven_gift) == 2
    assert Card.type(:elven_gift) == :action
    assert Card.faction(:elven_gift) == :wild
    assert not Card.champion?(:elven_gift)
    assert not Card.guard?(:elven_gift)

    [elven_gift] = Cards.with_id(:elven_gift)
    [cron] = Cards.with_id(:cron)
    [gold] = Cards.with_id(:gold)
    [gem] = Cards.with_id(:gem)

    {id, card} = elven_gift
    expended_elven_gift = {id, %{card | ally_ability_used: true}}

    # some cards to draw

    p1 = %{Player.empty() | hand: [gold, elven_gift], fight_zone: [cron], discard: [gem]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(elven_gift, 0))

    p1 = %{
      p1
      | hand: [gold],
        fight_zone: [cron, elven_gift],
        gold: 2,
        pending_interactions: [:draw_then_discard]
    }

    assert Game.player(game, "p1") == p1

    before_interact = {game, p1}

    # interact: draw
    assert {:ok, game} = Game.interact(game, "p1", {:draw_then_discard, true})

    p1 = %{p1 | pending_interactions: [:discard_card], hand: [gold, gem], discard: []}

    assert Game.player(game, "p1") == p1

    assert {:ok, game} = Game.interact(game, "p1", {:discard_card, elem(gold, 0)})

    p1 = %{p1 | pending_interactions: [], hand: [gem], discard: [gold]}

    assert Game.player(game, "p1") == p1

    # interact: don't draw
    {game, p1} = before_interact

    assert {:ok, game} = Game.interact(game, "p1", {:draw_then_discard, false})

    p1 = %{p1 | pending_interactions: []}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(elven_gift, 0))

    p1 = %{p1 | fight_zone: [cron, expended_elven_gift], combat: 4}

    assert Game.player(game, "p1") == p1

    # no cards to draw

    p1 = %{Player.empty() | hand: [gold, elven_gift], fight_zone: [cron]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(elven_gift, 0))

    p1 = %{p1 | hand: [gold], fight_zone: [cron, elven_gift], gold: 2}

    assert Game.player(game, "p1") == p1
  end

  test "grak" do
    assert Card.cost(:grak) == 8
    assert Card.type(:grak) == {:guard, 7}
    assert Card.faction(:grak) == :wild
    assert Card.champion?(:grak)
    assert Card.guard?(:grak)

    [grak] = Cards.with_id(:grak)
    [cron] = Cards.with_id(:cron)
    [gold] = Cards.with_id(:gold)
    [gem] = Cards.with_id(:gem)
    [dagger] = Cards.with_id(:dagger)

    {id, card} = grak
    expended_grak = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_grak
    full_expended_grak = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [grak, gold], fight_zone: [cron], deck: [gem, dagger]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(grak, 0))

    p1 = %{p1 | hand: [gold], fight_zone: [cron, grak]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(grak, 0))

    p1 = %{
      p1
      | fight_zone: [cron, expended_grak],
        combat: 6,
        pending_interactions: [:draw_then_discard]
    }

    assert Game.player(game, "p1") == p1

    # interact
    assert {:ok, game} = Game.interact(game, "p1", {:draw_then_discard, true})

    p1 = %{p1 | pending_interactions: [:discard_card], hand: [gold, gem], deck: [dagger]}

    assert Game.player(game, "p1") == p1

    assert {:ok, game} = Game.interact(game, "p1", {:discard_card, elem(gold, 0)})

    p1 = %{p1 | pending_interactions: [], hand: [gem], discard: [gold]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(grak, 0))

    p1 = %{
      p1
      | fight_zone: [cron, full_expended_grak],
        pending_interactions: [:draw_then_discard]
    }

    assert Game.player(game, "p1") == p1
  end

  test "natures_bounty" do
    assert Card.cost(:natures_bounty) == 4
    assert Card.type(:natures_bounty) == :action
    assert Card.faction(:natures_bounty) == :wild
    assert not Card.champion?(:natures_bounty)
    assert not Card.guard?(:natures_bounty)

    [natures_bounty] = Cards.with_id(:natures_bounty)
    [cron] = Cards.with_id(:cron)
    [dagger] = Cards.with_id(:dagger)

    {id, card} = natures_bounty
    expended_natures_bounty = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [natures_bounty], fight_zone: [cron]}
    p2 = %{Player.empty() | hand: [dagger]}
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(natures_bounty, 0))

    p1 = %{p1 | hand: [], fight_zone: [cron, natures_bounty], gold: 4}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(natures_bounty, 0))

    p1 = %{
      p1
      | fight_zone: [cron, expended_natures_bounty],
        pending_interactions: [:target_opponent_to_discard]
    }

    assert Game.player(game, "p1") == p1

    # interact
    assert {:ok, game} = Game.interact(game, "p1", {:target_opponent_to_discard, "p2"})

    p1 = %{p1 | fight_zone: [cron, expended_natures_bounty], pending_interactions: []}
    p2 = %{p2 | pending_interactions: [:discard_card]}

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2

    # sacrifice
    assert {:ok, game} = Game.use_sacrifice_ability(game, "p1", elem(natures_bounty, 0))

    p1 = %{p1 | fight_zone: [cron], combat: 4}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [natures_bounty]
  end

  test "orc_grunt" do
    assert Card.cost(:orc_grunt) == 3
    assert Card.type(:orc_grunt) == {:guard, 3}
    assert Card.faction(:orc_grunt) == :wild
    assert Card.champion?(:orc_grunt)
    assert Card.guard?(:orc_grunt)

    [orc_grunt] = Cards.with_id(:orc_grunt)
    [cron] = Cards.with_id(:cron)
    [dagger] = Cards.with_id(:dagger)

    {id, card} = orc_grunt
    expended_orc_grunt = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_orc_grunt
    full_expended_orc_grunt = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [orc_grunt], fight_zone: [cron], deck: [dagger]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(orc_grunt, 0))

    p1 = %{p1 | hand: [], fight_zone: [cron, orc_grunt]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(orc_grunt, 0))

    p1 = %{p1 | fight_zone: [cron, expended_orc_grunt], combat: 2}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(orc_grunt, 0))

    p1 = %{p1 | fight_zone: [cron, full_expended_orc_grunt], hand: [dagger], deck: []}

    assert Game.player(game, "p1") == p1
  end

  test "rampage" do
    assert Card.cost(:rampage) == 6
    assert Card.type(:rampage) == :action
    assert Card.faction(:rampage) == :wild
    assert not Card.champion?(:rampage)
    assert not Card.guard?(:rampage)

    [rampage] = Cards.with_id(:rampage)
    [dagger] = Cards.with_id(:dagger)
    [gold] = Cards.with_id(:gold)

    # no cards to draw

    p1 = %{Player.empty() | hand: [rampage]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(rampage, 0))

    p1 = %{p1 | hand: [], fight_zone: [rampage], combat: 6}

    assert Game.player(game, "p1") == p1

    # 1 card to draw

    p1 = %{Player.empty() | hand: [rampage], discard: [dagger]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(rampage, 0))

    p1 = %{
      p1
      | hand: [],
        fight_zone: [rampage],
        combat: 6,
        pending_interactions: [:draw_then_discard]
    }

    assert Game.player(game, "p1") == p1

    # 2 cards to draw

    p1 = %{Player.empty() | hand: [rampage], deck: [gold, dagger]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(rampage, 0))

    p1 = %{
      p1
      | hand: [],
        fight_zone: [rampage],
        combat: 6,
        pending_interactions: [:draw_then_discard, :draw_then_discard]
    }

    assert Game.player(game, "p1") == p1

    before_interact = {game, p1}

    # interact: draw, draw
    assert {:ok, game} = Game.interact(game, "p1", {:draw_then_discard, true})

    p1 = %{
      p1
      | pending_interactions: [:draw_then_discard, :discard_card],
        hand: [gold],
        deck: [dagger]
    }

    assert Game.player(game, "p1") == p1

    #
    assert {:ok, game} = Game.interact(game, "p1", {:draw_then_discard, true})

    p1 = %{
      p1
      | pending_interactions: [:discard_card, :discard_card],
        hand: [gold, dagger],
        deck: []
    }

    assert Game.player(game, "p1") == p1

    # interact: don't draw
    {game, p1} = before_interact

    assert {:ok, game} = Game.interact(game, "p1", {:draw_then_discard, false})

    p1 = %{p1 | pending_interactions: []}

    assert Game.player(game, "p1") == p1

    # interact: draw, don't draw
    {game, p1} = before_interact

    assert {:ok, game} = Game.interact(game, "p1", {:draw_then_discard, true})

    p1 = %{
      p1
      | pending_interactions: [:draw_then_discard, :discard_card],
        hand: [gold],
        deck: [dagger]
    }

    assert Game.player(game, "p1") == p1

    #
    assert {:ok, game} = Game.interact(game, "p1", {:draw_then_discard, false})

    p1 = %{p1 | pending_interactions: [:discard_card]}

    assert Game.player(game, "p1") == p1
  end

  test "torgen" do
    assert Card.cost(:torgen) == 7
    assert Card.type(:torgen) == {:guard, 7}
    assert Card.faction(:torgen) == :wild
    assert Card.champion?(:torgen)
    assert Card.guard?(:torgen)

    [torgen] = Cards.with_id(:torgen)
    [gold] = Cards.with_id(:gold)

    {id, card} = torgen
    expended_torgen = {id, %{card | expend_ability_used: true}}

    p1 = %{Player.empty() | hand: [torgen]}
    p2 = %{Player.empty() | hand: [gold]}
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(torgen, 0))

    p1 = %{p1 | hand: [], fight_zone: [torgen]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(torgen, 0))

    p1 = %{
      p1
      | fight_zone: [expended_torgen],
        combat: 4,
        pending_interactions: [:target_opponent_to_discard]
    }

    assert Game.player(game, "p1") == p1
  end

  test "spark" do
    assert Card.cost(:spark) == 1
    assert Card.type(:spark) == :action
    assert Card.faction(:spark) == :wild
    assert not Card.champion?(:spark)
    assert not Card.guard?(:spark)

    [spark] = Cards.with_id(:spark)
    [cron] = Cards.with_id(:cron)
    [gold] = Cards.with_id(:gold)

    {id, card} = spark
    expended_spark = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [spark], fight_zone: [cron]}
    p2 = %{Player.empty() | hand: [gold]}
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(spark, 0))

    p1 = %{
      p1
      | hand: [],
        fight_zone: [cron, spark],
        combat: 3,
        pending_interactions: [:target_opponent_to_discard]
    }

    assert Game.player(game, "p1") == p1

    # interact
    assert {:ok, game} = Game.interact(game, "p1", {:target_opponent_to_discard, "p2"})

    p1 = %{p1 | pending_interactions: []}
    p2 = %{p2 | pending_interactions: [:discard_card]}

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(spark, 0))

    p1 = %{p1 | fight_zone: [cron, expended_spark], combat: 5}

    assert Game.player(game, "p1") == p1
  end

  test "wolf_form" do
    assert Card.cost(:wolf_form) == 5
    assert Card.type(:wolf_form) == :action
    assert Card.faction(:wolf_form) == :wild
    assert not Card.champion?(:wolf_form)
    assert not Card.guard?(:wolf_form)

    [wolf_form] = Cards.with_id(:wolf_form)
    [gold] = Cards.with_id(:gold)

    p1 = %{Player.empty() | hand: [wolf_form]}
    p2 = %{Player.empty() | hand: [gold]}
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(wolf_form, 0))

    p1 = %{
      p1
      | hand: [],
        fight_zone: [wolf_form],
        combat: 8,
        pending_interactions: [:target_opponent_to_discard]
    }

    assert Game.player(game, "p1") == p1

    # interact
    assert {:ok, game} = Game.interact(game, "p1", {:target_opponent_to_discard, "p2"})

    p1 = %{p1 | pending_interactions: []}
    p2 = %{p2 | pending_interactions: [:discard_card]}

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2

    # sacrifice
    assert {:ok, game} = Game.use_sacrifice_ability(game, "p1", elem(wolf_form, 0))

    p1 = %{p1 | fight_zone: [], pending_interactions: [:target_opponent_to_discard]}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [wolf_form]
  end

  test "wolf_shaman" do
    assert Card.cost(:wolf_shaman) == 2
    assert Card.type(:wolf_shaman) == {:not_guard, 4}
    assert Card.faction(:wolf_shaman) == :wild
    assert Card.champion?(:wolf_shaman)
    assert not Card.guard?(:wolf_shaman)

    [wolf_shaman] = Cards.with_id(:wolf_shaman)
    [cron] = Cards.with_id(:cron)
    [torgen] = Cards.with_id(:torgen)
    [arkus] = Cards.with_id(:arkus)

    {id, card} = wolf_shaman
    expended_wolf_shaman = {id, %{card | expend_ability_used: true}}

    p1 = %{Player.empty() | hand: [wolf_shaman], fight_zone: [cron, torgen, arkus]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(wolf_shaman, 0))

    p1 = %{p1 | hand: [], fight_zone: [cron, torgen, arkus, wolf_shaman]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(wolf_shaman, 0))

    p1 = %{p1 | fight_zone: [cron, torgen, arkus, expended_wolf_shaman], combat: 4}

    assert Game.player(game, "p1") == p1
  end
end
