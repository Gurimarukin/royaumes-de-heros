defmodule Heros.Cards.NecrosTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

  test "cult_priest" do
    assert Card.cost(:cult_priest) == 3
    assert Card.type(:cult_priest) == {:not_guard, 4}
    assert Card.faction(:cult_priest) == :necros
    assert Card.champion?(:cult_priest)
    assert not Card.guard?(:cult_priest)

    [cult_priest] = Cards.with_id(:cult_priest)
    [lys] = Cards.with_id(:lys)

    {id, card} = cult_priest
    expended_cult_priest = {id, %{card | ally_ability_used: true}}

    {id, card} = expended_cult_priest
    full_expended_cult_priest = {id, %{card | expend_ability_used: true}}

    p1 = %{Player.empty() | hand: [cult_priest], fight_zone: [lys]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(cult_priest, 0))

    p1 = %{p1 | hand: [], fight_zone: [lys, cult_priest]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(cult_priest, 0))

    p1 = %{p1 | combat: 4, fight_zone: [lys, expended_cult_priest]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(cult_priest, 0))

    p1 = %{
      p1
      | pending_interactions: [select_effect: [add_gold: 1, add_combat: 1]],
        fight_zone: [lys, full_expended_cult_priest]
    }

    assert Game.player(game, "p1") == p1

    before_interact = {game, p1}

    # interaction 0
    assert {:ok, game} = Game.interact(game, "p1", {:select_effect, 0})

    p1 = %{p1 | gold: 1, pending_interactions: []}

    assert Game.player(game, "p1") == p1

    # interaction 1
    {game, p1} = before_interact

    assert {:ok, game} = Game.interact(game, "p1", {:select_effect, 1})

    p1 = %{p1 | combat: 5, pending_interactions: []}

    assert Game.player(game, "p1") == p1
  end

  test "dark_energy" do
    assert Card.cost(:dark_energy) == 4
    assert Card.type(:dark_energy) == :action
    assert Card.faction(:dark_energy) == :necros
    assert not Card.champion?(:dark_energy)
    assert not Card.guard?(:dark_energy)

    [dark_energy] = Cards.with_id(:dark_energy)
    [lys] = Cards.with_id(:lys)
    [gem] = Cards.with_id(:gem)

    {id, card} = dark_energy
    expended_dark_energy = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [dark_energy], fight_zone: [lys], deck: [gem]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(dark_energy, 0))

    p1 = %{p1 | combat: 7, hand: [], fight_zone: [lys, dark_energy]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(dark_energy, 0))

    p1 = %{p1 | hand: [gem], deck: [], fight_zone: [lys, expended_dark_energy]}

    assert Game.player(game, "p1") == p1
  end

  test "dark_reward" do
    assert Card.cost(:dark_reward) == 5
    assert Card.type(:dark_reward) == :action
    assert Card.faction(:dark_reward) == :necros
    assert not Card.champion?(:dark_reward)
    assert not Card.guard?(:dark_reward)

    [dark_reward] = Cards.with_id(:dark_reward)
    [lys] = Cards.with_id(:lys)
    [gold1, gold2] = Cards.with_id(:gold, 2)
    [dagger] = Cards.with_id(:dagger)
    [shortsword] = Cards.with_id(:shortsword)

    {id, card} = dark_reward
    expended_dark_reward = {id, %{card | ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | hand: [dagger, dark_reward],
        fight_zone: [lys],
        discard: [gold1, gold2]
    }

    p2 = Player.empty()
    game = %{Game.empty([{"p1", p1}, {"p2", p2}], "p1") | cemetery: [shortsword]}

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(dark_reward, 0))

    p1 = %{
      p1
      | hand: [dagger],
        fight_zone: [lys, dark_reward],
        gold: 3,
        pending_interactions: [sacrifice_from_hand_or_discard: %{amount: 1, combat_per_card: 0}]
    }

    assert Game.player(game, "p1") == p1

    before_interact = {game, p1}

    # sacrifice from hand
    assert {:ok, game} =
             Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, [elem(dagger, 0)]})

    p1 = %{p1 | pending_interactions: [], hand: []}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [dagger, shortsword]

    # sacrifice from discard
    {game, p1} = before_interact

    assert {:ok, game} =
             Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, [elem(gold2, 0)]})

    p1 = %{p1 | pending_interactions: [], discard: [gold1]}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [gold2, shortsword]

    # don't sacrifice
    {game, p1} = before_interact

    assert {:ok, game} = Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, []})

    p1 = %{p1 | pending_interactions: []}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [shortsword]

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(dark_reward, 0))

    p1 = %{p1 | fight_zone: [lys, expended_dark_reward], combat: 6}

    assert Game.player(game, "p1") == p1
  end

  test "death_cultist" do
    assert Card.cost(:death_cultist) == 2
    assert Card.type(:death_cultist) == {:guard, 3}
    assert Card.faction(:death_cultist) == :necros
    assert Card.champion?(:death_cultist)
    assert Card.guard?(:death_cultist)

    [death_cultist] = Cards.with_id(:death_cultist)

    {id, card} = death_cultist
    expended_death_cultist = {id, %{card | expend_ability_used: true}}

    p1 = %{Player.empty() | hand: [death_cultist]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(death_cultist, 0))

    p1 = %{p1 | hand: [], fight_zone: [death_cultist]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(death_cultist, 0))

    p1 = %{p1 | fight_zone: [expended_death_cultist], combat: 2}

    assert Game.player(game, "p1") == p1
  end

  test "death_touch" do
    assert Card.cost(:death_touch) == 1
    assert Card.type(:death_touch) == :action
    assert Card.faction(:death_touch) == :necros
    assert not Card.champion?(:death_touch)
    assert not Card.guard?(:death_touch)

    [death_touch] = Cards.with_id(:death_touch)
    [lys] = Cards.with_id(:lys)
    [gold] = Cards.with_id(:gold)

    {id, card} = death_touch
    expended_death_touch = {id, %{card | ally_ability_used: true}}

    # primary with cards in hand or discard
    p1 = %{Player.empty() | hand: [gold, death_touch], fight_zone: [lys]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(death_touch, 0))

    p1 = %{
      p1
      | hand: [gold],
        fight_zone: [lys, death_touch],
        combat: 2,
        pending_interactions: [sacrifice_from_hand_or_discard: %{amount: 1, combat_per_card: 0}]
    }

    assert Game.player(game, "p1") == p1

    # interact
    assert {:ok, game} = Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, []})

    p1 = %{p1 | pending_interactions: []}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == []

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(death_touch, 0))

    p1 = %{p1 | fight_zone: [lys, expended_death_touch], combat: 4}

    assert Game.player(game, "p1") == p1

    # primary without cards in hand or discard
    p1 = %{Player.empty() | hand: [death_touch], fight_zone: [lys]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(death_touch, 0))

    p1 = %{p1 | hand: [], fight_zone: [lys, death_touch], combat: 2}

    assert Game.player(game, "p1") == p1
  end

  test "rayla" do
    assert Card.cost(:rayla) == 4
    assert Card.type(:rayla) == {:not_guard, 4}
    assert Card.faction(:rayla) == :necros
    assert Card.champion?(:rayla)
    assert not Card.guard?(:rayla)

    [rayla] = Cards.with_id(:rayla)
    [lys] = Cards.with_id(:lys)
    [gold] = Cards.with_id(:gold)

    {id, card} = rayla
    expended_rayla = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_rayla
    full_expended_rayla = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [rayla], fight_zone: [lys], deck: [gold]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(rayla, 0))

    p1 = %{p1 | hand: [], fight_zone: [lys, rayla]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(rayla, 0))

    p1 = %{p1 | fight_zone: [lys, expended_rayla], combat: 3}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(rayla, 0))

    p1 = %{p1 | fight_zone: [lys, full_expended_rayla], hand: [gold], deck: []}

    assert Game.player(game, "p1") == p1
  end

  test "influence" do
    assert Card.cost(:influence) == 2
    assert Card.type(:influence) == :action
    assert Card.faction(:influence) == :necros
    assert not Card.champion?(:influence)
    assert not Card.guard?(:influence)

    [influence] = Cards.with_id(:influence)

    p1 = %{Player.empty() | hand: [influence]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(influence, 0))

    p1 = %{p1 | hand: [], fight_zone: [influence], gold: 3}

    assert Game.player(game, "p1") == p1

    # sacrifice
    assert {:ok, game} = Game.use_sacrifice_ability(game, "p1", elem(influence, 0))

    p1 = %{p1 | fight_zone: [], combat: 3}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [influence]
  end

  test "krythos" do
    assert Card.cost(:krythos) == 7
    assert Card.type(:krythos) == {:not_guard, 6}
    assert Card.faction(:krythos) == :necros
    assert Card.champion?(:krythos)
    assert not Card.guard?(:krythos)

    [krythos] = Cards.with_id(:krythos)
    [gold] = Cards.with_id(:gold)

    {id, card} = krythos
    expended_krythos = {id, %{card | expend_ability_used: true}}

    # with card in discard

    p1 = %{Player.empty() | hand: [krythos], discard: [gold]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(krythos, 0))

    p1 = %{p1 | hand: [], fight_zone: [krythos]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(krythos, 0))

    p1 = %{
      p1
      | hand: [],
        fight_zone: [expended_krythos],
        combat: 3,
        pending_interactions: [sacrifice_from_hand_or_discard: %{amount: 1, combat_per_card: 3}]
    }

    assert Game.player(game, "p1") == p1

    before_interact = {game, p1}

    # use sacrifice
    assert {:ok, game} =
             Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, [elem(gold, 0)]})

    p1 = %{p1 | discard: [], pending_interactions: [], combat: 6}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [gold]

    # don't use sacrifice
    {game, p1} = before_interact

    assert {:ok, game} = Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, []})

    p1 = %{p1 | pending_interactions: []}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == []

    # without card to sacrifice

    p1 = %{Player.empty() | hand: [krythos]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(krythos, 0))

    p1 = %{p1 | hand: [], fight_zone: [krythos]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(krythos, 0))

    p1 = %{p1 | hand: [], fight_zone: [expended_krythos], combat: 3}

    assert Game.player(game, "p1") == p1
  end

  test "life_drain" do
    assert Card.cost(:life_drain) == 6
    assert Card.type(:life_drain) == :action
    assert Card.faction(:life_drain) == :necros
    assert not Card.champion?(:life_drain)
    assert not Card.guard?(:life_drain)

    [life_drain] = Cards.with_id(:life_drain)
    [lys] = Cards.with_id(:lys)
    [gem] = Cards.with_id(:gem)
    [gold] = Cards.with_id(:gold)

    {id, card} = life_drain
    expended_life_drain = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [gold, life_drain], fight_zone: [lys], deck: [gem]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(life_drain, 0))

    p1 = %{
      p1
      | hand: [gold],
        fight_zone: [lys, life_drain],
        combat: 8,
        pending_interactions: [sacrifice_from_hand_or_discard: %{amount: 1, combat_per_card: 0}]
    }

    assert Game.player(game, "p1") == p1

    # interact
    assert {:ok, game} =
             Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, [elem(gold, 0)]})

    p1 = %{p1 | pending_interactions: [], hand: []}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [gold]

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(life_drain, 0))

    p1 = %{p1 | fight_zone: [lys, expended_life_drain], hand: [gem], deck: []}

    assert Game.player(game, "p1") == p1
  end

  test "lys" do
    assert Card.cost(:lys) == 6
    assert Card.type(:lys) == {:guard, 5}
    assert Card.faction(:lys) == :necros
    assert Card.champion?(:lys)
    assert Card.guard?(:lys)

    [lys] = Cards.with_id(:lys)
    [gold] = Cards.with_id(:gold)

    {id, card} = lys
    expended_lys = {id, %{card | expend_ability_used: true}}

    p1 = %{Player.empty() | hand: [gold, lys]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(lys, 0))

    p1 = %{p1 | hand: [gold], fight_zone: [lys]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(lys, 0))

    p1 = %{
      p1
      | fight_zone: [expended_lys],
        combat: 2,
        pending_interactions: [sacrifice_from_hand_or_discard: %{amount: 1, combat_per_card: 2}]
    }

    assert Game.player(game, "p1") == p1

    # interact
    assert {:ok, game} =
             Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, [elem(gold, 0)]})

    p1 = %{p1 | pending_interactions: [], hand: [], combat: 4}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [gold]
  end

  test "the_rot" do
    assert Card.cost(:the_rot) == 3
    assert Card.type(:the_rot) == :action
    assert Card.faction(:the_rot) == :necros
    assert not Card.champion?(:the_rot)
    assert not Card.guard?(:the_rot)

    [the_rot] = Cards.with_id(:the_rot)
    [lys] = Cards.with_id(:lys)
    [gold] = Cards.with_id(:gold)

    {id, card} = the_rot
    expended_the_rot = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [gold, the_rot], fight_zone: [lys]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(the_rot, 0))

    p1 = %{
      p1
      | hand: [gold],
        fight_zone: [lys, the_rot],
        combat: 4,
        pending_interactions: [sacrifice_from_hand_or_discard: %{amount: 1, combat_per_card: 0}]
    }

    assert Game.player(game, "p1") == p1

    # interact
    assert {:ok, game} =
             Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, [elem(gold, 0)]})

    p1 = %{p1 | pending_interactions: [], hand: []}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [gold]

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(the_rot, 0))

    p1 = %{p1 | fight_zone: [lys, expended_the_rot], combat: 7}

    assert Game.player(game, "p1") == p1
  end

  test "tyrannor" do
    assert Card.cost(:tyrannor) == 8
    assert Card.type(:tyrannor) == {:guard, 6}
    assert Card.faction(:tyrannor) == :necros
    assert Card.champion?(:tyrannor)
    assert Card.guard?(:tyrannor)

    [tyrannor] = Cards.with_id(:tyrannor)
    [lys] = Cards.with_id(:lys)
    [gold1, gold2] = Cards.with_id(:gold, 2)
    [dagger] = Cards.with_id(:dagger)
    [gem] = Cards.with_id(:gem)

    {id, card} = tyrannor
    expended_tyrannor = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_tyrannor
    full_expended_tyrannor = {id, %{card | ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | hand: [gold1, gold2, tyrannor],
        fight_zone: [lys],
        discard: [dagger],
        deck: [gem]
    }

    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(tyrannor, 0))

    p1 = %{p1 | hand: [gold1, gold2], fight_zone: [lys, tyrannor]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(tyrannor, 0))

    p1 = %{
      p1
      | fight_zone: [lys, expended_tyrannor],
        combat: 4,
        pending_interactions: [
          sacrifice_from_hand_or_discard: %{amount: 2, combat_per_card: 0}
        ]
    }

    assert Game.player(game, "p1") == p1

    before_interact = {game, p1}

    # can't sacrifice that many cards
    assert :error =
             Game.interact(
               game,
               "p1",
               {:sacrifice_from_hand_or_discard,
                [elem(gold1, 0), elem(gold2, 0), elem(dagger, 0)]}
             )

    # can't sacrifice the same card twice
    assert :error =
             Game.interact(
               game,
               "p1",
               {:sacrifice_from_hand_or_discard, [elem(gold1, 0), elem(gold1, 0)]}
             )

    # interact 0
    assert {:ok, game} = Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, []})

    p1 = %{p1 | pending_interactions: []}

    assert Game.player(game, "p1") == p1

    # interact 1
    {game, p1} = before_interact

    assert {:ok, game} =
             Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, [elem(gold1, 0)]})

    p1 = %{p1 | pending_interactions: [], hand: [gold2]}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [gold1]

    # interact 2
    {game, p1} = before_interact

    assert {:ok, game} =
             Game.interact(
               game,
               "p1",
               {:sacrifice_from_hand_or_discard, [elem(gold1, 0), elem(dagger, 0)]}
             )

    p1 = %{p1 | pending_interactions: [], hand: [gold2], discard: []}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [dagger, gold1]

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(tyrannor, 0))

    p1 = %{p1 | fight_zone: [lys, full_expended_tyrannor], hand: [gold2, gem], deck: []}

    assert Game.player(game, "p1") == p1
  end

  test "varrick" do
    assert Card.cost(:varrick) == 5
    assert Card.type(:varrick) == {:not_guard, 3}
    assert Card.faction(:varrick) == :necros
    assert Card.champion?(:varrick)
    assert not Card.guard?(:varrick)

    [varrick] = Cards.with_id(:varrick)
    [lys] = Cards.with_id(:lys)
    [arkus] = Cards.with_id(:arkus)
    [gold] = Cards.with_id(:gold)
    [gem] = Cards.with_id(:gem)

    {id, card} = varrick
    expended_varrick = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_varrick
    full_expended_varrick = {id, %{card | ally_ability_used: true}}

    # with a champion in discard

    p1 = %{
      Player.empty()
      | hand: [varrick],
        fight_zone: [lys],
        discard: [arkus, gold],
        deck: [gem]
    }

    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(varrick, 0))

    p1 = %{p1 | hand: [], fight_zone: [lys, varrick]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(varrick, 0))

    p1 = %{
      p1
      | fight_zone: [lys, expended_varrick],
        pending_interactions: [:put_champion_from_discard_to_deck]
    }

    assert Game.player(game, "p1") == p1

    # not a champion
    assert :error = Game.interact(game, "p1", {:put_champion_from_discard_to_deck, elem(gold, 0)})

    before_interact = {game, p1}

    # interact
    assert {:ok, game} =
             Game.interact(game, "p1", {:put_champion_from_discard_to_deck, elem(arkus, 0)})

    p1 = %{p1 | pending_interactions: [], discard: [gold], deck: [arkus, gem]}

    assert Game.player(game, "p1") == p1

    # don't interact
    {game, p1} = before_interact

    assert {:ok, game} = Game.interact(game, "p1", {:put_champion_from_discard_to_deck, nil})

    p1 = %{p1 | pending_interactions: []}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(varrick, 0))

    p1 = %{p1 | fight_zone: [lys, full_expended_varrick], hand: [gem], deck: []}

    assert Game.player(game, "p1") == p1

    # without a champion in discard

    p1 = %{
      Player.empty()
      | hand: [varrick],
        fight_zone: [lys],
        discard: [gold],
        deck: [gem]
    }

    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(varrick, 0))

    p1 = %{p1 | hand: [], fight_zone: [lys, varrick]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(varrick, 0))

    p1 = %{p1 | fight_zone: [lys, expended_varrick]}

    assert Game.player(game, "p1") == p1
  end
end
