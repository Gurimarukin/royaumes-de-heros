defmodule Heros.Cards.Decks.BaseTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

  test "shortsword" do
    assert Card.cost(:shortsword) == nil
    assert Card.type(:shortsword) == :item
    assert Card.faction(:shortsword) == nil
    assert not Card.champion?(:shortsword)
    assert not Card.guard?(:shortsword)

    [shortsword] = Cards.with_id(:shortsword)

    p1 = %{Player.empty() | hand: [shortsword]}
    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(shortsword, 0))

    p1 = Game.player(game, "p1")

    assert p1.combat == 2
  end

  test "dagger" do
    assert Card.cost(:dagger) == nil
    assert Card.type(:dagger) == :item
    assert Card.faction(:dagger) == nil
    assert not Card.champion?(:dagger)
    assert not Card.guard?(:dagger)

    [dagger] = Cards.with_id(:dagger)

    p1 = %{Player.empty() | hand: [dagger]}
    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(dagger, 0))

    p1 = Game.player(game, "p1")

    assert p1.combat == 1
  end

  test "ruby" do
    assert Card.cost(:ruby) == nil
    assert Card.type(:ruby) == :item
    assert Card.faction(:ruby) == nil
    assert not Card.champion?(:ruby)
    assert not Card.guard?(:ruby)

    [ruby] = Cards.with_id(:ruby)

    p1 = %{Player.empty() | hand: [ruby]}
    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(ruby, 0))

    p1 = Game.player(game, "p1")

    assert p1.gold == 2
  end

  test "gold" do
    assert Card.cost(:gold) == nil
    assert Card.type(:gold) == :item
    assert Card.faction(:gold) == nil
    assert not Card.champion?(:gold)
    assert not Card.guard?(:gold)

    [gold] = Cards.with_id(:gold)

    p1 = %{Player.empty() | hand: [gold]}
    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(gold, 0))

    p1 = Game.player(game, "p1")

    assert p1.gold == 1
  end

  test "gem" do
    assert Card.cost(:gem) == 2
    assert Card.type(:gem) == :item
    assert Card.faction(:gem) == nil
    assert not Card.champion?(:gem)
    assert not Card.guard?(:gem)

    [gem1, gem2] = Cards.with_id(:gem, 2)

    p1 = %{Player.empty() | hand: [gem1]}
    p2 = Player.empty()

    game = %{Game.empty([{"p1", p1}, {"p2", p2}], "p1") | gems: [gem2]}

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(gem1, 0))

    p1 = %{p1 | gold: 2, hand: [], fight_zone: [gem1]}

    assert Game.player(game, "p1") == p1

    # sacrifice
    assert {:ok, game} = Game.use_sacrifice_ability(game, "p1", elem(gem1, 0))

    p1 = %{p1 | combat: 3, fight_zone: []}

    assert Game.player(game, "p1") == p1
    assert game.gems == [gem1, gem2]
  end
end
