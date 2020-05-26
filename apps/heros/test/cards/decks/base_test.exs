defmodule Heros.Cards.Decks.BaseTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

  test "shortsword" do
    assert Card.cost(:shortsword) == nil
    assert Card.type(:shortsword) == :item
    assert Card.faction(:shortsword) == nil
    assert not Card.is_champion(:shortsword)
    assert not Card.is_guard(:shortsword)

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
    assert not Card.is_champion(:dagger)
    assert not Card.is_guard(:dagger)

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
    assert not Card.is_champion(:ruby)
    assert not Card.is_guard(:ruby)

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
    assert not Card.is_champion(:gold)
    assert not Card.is_guard(:gold)

    [gold] = Cards.with_id(:gold)

    p1 = %{Player.empty() | hand: [gold]}
    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(gold, 0))

    p1 = Game.player(game, "p1")

    assert p1.gold == 1
  end
end
