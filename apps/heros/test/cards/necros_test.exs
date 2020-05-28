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
end
