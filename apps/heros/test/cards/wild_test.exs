defmodule Heros.Cards.WildTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

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
  end

  test "dire_wolf" do
  end

  test "elven_curse" do
  end

  test "elven_gift" do
  end

  test "grak" do
  end

  test "natures_bounty" do
  end

  test "orc_grunt" do
  end

  test "rampage" do
  end

  test "torgen" do
  end

  test "spark" do
  end

  test "wolf_form" do
  end

  test "wolf_shaman" do
  end
end
