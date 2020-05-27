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

  test "rasmus" do
    assert Card.cost(:rasmus) == 4
    assert Card.type(:rasmus) == {:not_guard, 5}
    assert Card.faction(:rasmus) == :guild
    assert Card.champion?(:rasmus)
    assert not Card.guard?(:rasmus)
  end
end
