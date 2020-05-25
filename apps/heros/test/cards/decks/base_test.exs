defmodule Heros.Cards.Decks.BaseTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, KeyListUtils, Player}
  alias Heros.Cards.Card

  test "shortsword" do
    assert Card.cost(:shortsword) == nil
    assert Card.type(:shortsword) == :item
    assert Card.faction(:shortsword) == nil

    [shortsword] = Cards.with_id(:shortsword)

    p1 = %{Player.empty() | hand: [shortsword]}
    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")
    {:ok, pid} = Game.GenServer.start({:from_game, game})

    assert Game.GenServer.play_card(pid, "p1", elem(shortsword, 0)) == :ok
    game = Game.GenServer.get(pid)
    p1 = KeyListUtils.find(game.players, "p1")

    assert p1.combat == 2
  end

  test "dagger" do
    assert Card.cost(:dagger) == nil
    assert Card.type(:dagger) == :item
    assert Card.faction(:dagger) == nil

    [dagger] = Cards.with_id(:dagger)

    p1 = %{Player.empty() | hand: [dagger]}
    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")
    {:ok, pid} = Game.GenServer.start({:from_game, game})

    assert Game.GenServer.play_card(pid, "p1", elem(dagger, 0)) == :ok
    game = Game.GenServer.get(pid)
    p1 = KeyListUtils.find(game.players, "p1")

    assert p1.combat == 1
  end

  test "ruby" do
    assert Card.cost(:ruby) == nil
    assert Card.type(:ruby) == :item
    assert Card.faction(:ruby) == nil

    [ruby] = Cards.with_id(:ruby)

    p1 = %{Player.empty() | hand: [ruby]}
    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")
    {:ok, pid} = Game.GenServer.start({:from_game, game})

    assert Game.GenServer.play_card(pid, "p1", elem(ruby, 0)) == :ok
    game = Game.GenServer.get(pid)
    p1 = KeyListUtils.find(game.players, "p1")

    assert p1.gold == 2
  end
end
