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
        pending_interactions: [:sacrifice_from_hand_or_discard]
    }

    assert Game.player(game, "p1") == p1

    before_interact = {game, p1}

    # sacrifice from hand
    assert {:ok, game} =
             Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, elem(dagger, 0)})

    p1 = %{p1 | pending_interactions: [], hand: []}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [dagger, shortsword]

    # sacrifice from discard
    {game, p1} = before_interact

    assert {:ok, game} =
             Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, elem(gold2, 0)})

    p1 = %{p1 | pending_interactions: [], discard: [gold1]}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [gold2, shortsword]

    # don't sacrifice
    {game, p1} = before_interact

    assert {:ok, game} = Game.interact(game, "p1", {:sacrifice_from_hand_or_discard, nil})

    p1 = %{p1 | pending_interactions: []}

    assert Game.player(game, "p1") == p1

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
end
