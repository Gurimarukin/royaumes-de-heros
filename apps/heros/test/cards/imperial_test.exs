defmodule Heros.Cards.ImperialTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, KeyListUtils, Player}
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
    {:ok, pid} = Game.GenServer.start({:from_game, game})

    # can't use expend or ally abilities, when card isn't in fight zone
    assert Game.GenServer.use_expend_ability(pid, "p1", elem(arkus, 0)) == :not_found
    assert Game.GenServer.use_ally_ability(pid, "p1", elem(arkus, 0)) == :not_found

    assert Game.GenServer.play_card(pid, "p1", elem(arkus, 0)) == :ok

    # can't use ally ability, as there aren't any allies on board
    assert Game.GenServer.use_ally_ability(pid, "p1", elem(arkus, 0)) == :forbidden

    # p2 can't do that
    assert Game.GenServer.use_expend_ability(pid, "p2", elem(arkus, 0)) == :forbidden

    assert Game.GenServer.use_expend_ability(pid, "p1", elem(arkus, 0)) == :ok

    p1 = Game.GenServer.get(pid).players |> KeyListUtils.find("p1")

    assert p1.combat == 5
    assert p1.hp == 10
    assert p1.fight_zone == [expended_arkus]
    assert p1.hand == [weyan, gem1]
    assert p1.deck == [gem2]

    # can't use expend ability as it was alredy used
    assert Game.GenServer.use_expend_ability(pid, "p1", elem(arkus, 0)) == :forbidden

    assert Game.GenServer.play_card(pid, "p1", elem(weyan, 0)) == :ok

    assert Game.GenServer.use_ally_ability(pid, "p1", elem(weyan, 0)) == :not_found

    # p2 can't do that
    assert Game.GenServer.use_ally_ability(pid, "p2", elem(arkus, 0)) == :forbidden

    assert Game.GenServer.use_ally_ability(pid, "p1", elem(arkus, 0)) == :ok

    p1 = Game.GenServer.get(pid).players |> KeyListUtils.find("p1")

    assert p1.combat == 5
    assert p1.hp == 16
    assert p1.fight_zone == [full_expended_arkus, weyan]
    assert p1.hand == [gem1]
    assert p1.deck == [gem2]

    # can't use abilities as they were alredy used
    assert Game.GenServer.use_expend_ability(pid, "p1", elem(arkus, 0)) == :forbidden
    assert Game.GenServer.use_ally_ability(pid, "p1", elem(arkus, 0)) == :forbidden
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
    {:ok, pid} = Game.GenServer.start({:from_game, game})

    assert Game.GenServer.play_card(pid, "p1", elem(weyan, 0)) == :ok
    assert Game.GenServer.play_card(pid, "p1", elem(arkus, 0)) == :ok
    assert Game.GenServer.use_ally_ability(pid, "p1", elem(arkus, 0)) == :ok

    p1 = Game.GenServer.get(pid).players |> KeyListUtils.find("p1")

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
    {:ok, pid} = Game.GenServer.start({:from_game, initial_game})

    assert Game.GenServer.play_card(pid, "p1", elem(close_ranks, 0)) == :ok

    assert Game.GenServer.use_expend_ability(pid, "p1", elem(close_ranks, 0)) == :not_found
    assert Game.GenServer.use_ally_ability(pid, "p1", elem(close_ranks, 0)) == :forbidden

    p1 = Game.GenServer.get(pid).players |> KeyListUtils.find("p1")
    assert p1.fight_zone == [close_ranks]
    assert p1.hand == [arkus, rasmus]
    assert p1.combat == 5
    assert p1.hp == 10

    assert Game.GenServer.play_card(pid, "p1", elem(arkus, 0)) == :ok
    assert Game.GenServer.use_ally_ability(pid, "p1", elem(close_ranks, 0)) == :ok

    p1 = Game.GenServer.get(pid).players |> KeyListUtils.find("p1")
    assert p1.fight_zone == [expended_close_ranks, arkus]
    assert p1.hand == [rasmus]
    assert p1.combat == 5
    assert p1.hp == 16

    assert Game.GenServer.play_card(pid, "p1", elem(rasmus, 0)) == :ok

    p1 = Game.GenServer.get(pid).players |> KeyListUtils.find("p1")
    assert p1.fight_zone == [expended_close_ranks, arkus, rasmus]
    assert p1.hand == []
    assert p1.combat == 5
    assert p1.hp == 16

    # with 1 champion in play
    {:ok, pid} = Game.GenServer.start({:from_game, initial_game})

    assert Game.GenServer.play_card(pid, "p1", elem(rasmus, 0)) == :ok
    assert Game.GenServer.play_card(pid, "p1", elem(close_ranks, 0)) == :ok

    p1 = Game.GenServer.get(pid).players |> KeyListUtils.find("p1")
    assert p1.fight_zone == [rasmus, close_ranks]
    assert p1.hand == [arkus]
    assert p1.combat == 7
    assert p1.hp == 10

    # with 2 champions in play
    {:ok, pid} = Game.GenServer.start({:from_game, initial_game})

    assert Game.GenServer.play_card(pid, "p1", elem(arkus, 0)) == :ok
    assert Game.GenServer.play_card(pid, "p1", elem(rasmus, 0)) == :ok
    assert Game.GenServer.play_card(pid, "p1", elem(close_ranks, 0)) == :ok

    p1 = Game.GenServer.get(pid).players |> KeyListUtils.find("p1")
    assert p1.fight_zone == [arkus, rasmus, close_ranks]
    assert p1.hand == []
    assert p1.combat == 9
    assert p1.hp == 10
  end
end
