defmodule Heros.GameTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, KeyListUtils, Player}

  test "creates game" do
    {:ok, pid} = Game.GenServer.start({:from_player_ids, ["p1", "p2"]})
    game = Game.GenServer.get(pid)

    # players
    assert [{"p1", _}, {"p2", _}] = game.players

    assert length(KeyListUtils.find(game.players, "p1").hand) == 3
    assert length(KeyListUtils.find(game.players, "p2").hand) == 5

    game.players
    |> Enum.map(fn {_, player} ->
      assert player.hp == 50
      assert player.max_hp == 50
      assert player.gold == 0
      assert player.combat == 0

      assert player.discard == []
      assert player.fight_zone == []

      assert length(player.hand) + length(player.deck) == 10
    end)

    # current_player
    assert game.current_player == "p1"

    # gems
    assert length(game.gems) == 16
    assert {_, %{key: :gem}} = hd(game.gems)

    # market
    assert length(game.market) == 5

    # market_deck
    assert length(game.market_deck) == length(Heros.Cards.market()) - 5

    # cemetery
    assert game.cemetery == []
  end

  test "creates 4 players game" do
    {:ok, pid} = Game.GenServer.start({:from_player_ids, ["p1", "p2", "p3", "p4"]})
    game = Game.GenServer.get(pid)

    assert length(KeyListUtils.find(game.players, "p1").hand) == 3
    assert length(KeyListUtils.find(game.players, "p2").hand) == 4
    assert length(KeyListUtils.find(game.players, "p3").hand) == 5
    assert length(KeyListUtils.find(game.players, "p4").hand) == 5
  end

  test "doesn't create game with invalid settings" do
    # not a list
    assert {:error, :invalid_players} = Game.GenServer.start({:from_player_ids, :pouet})
    # less than 2 elements
    assert {:error, :invalid_players} = Game.GenServer.start({:from_player_ids, [:a]})
  end

  test "playing cards moves them from hand to fight zone" do
    {:ok, pid} = Game.GenServer.start({:from_player_ids, ["p1", "p2"]})
    game = Game.GenServer.get(pid)
    p1 = KeyListUtils.find(game.players, "p1")
    p2 = KeyListUtils.find(game.players, "p2")

    [{id, _}, _, _, _, _] = p2.hand

    # b can't play as he isn't current player
    assert Game.GenServer.play_card(pid, "p2", id) == :error
    # a can't play b's card
    assert Game.GenServer.play_card(pid, "p1", id) == :error

    [{id1, card1}, {id2, card2}, {id3, card3}] = p1.hand

    # player not found, he isn't current player
    assert Game.GenServer.play_card(pid, "p3", id1) == :error
    # card not found
    assert Game.GenServer.play_card(pid, "p1", "whatever") == :error

    assert {:ok, game} = Game.GenServer.play_card(pid, "p1", id1)

    p1 = KeyListUtils.find(game.players, "p1")

    assert [{^id2, ^card2}, {^id3, ^card3}] = p1.hand
    assert p1.fight_zone == [{id1, card1}]

    assert Game.GenServer.play_card(pid, "p1", id1) == :error

    assert {:ok, game} = Game.GenServer.play_card(pid, "p1", id3)
    p1 = KeyListUtils.find(game.players, "p1")

    assert [{^id2, ^card2}] = p1.hand
    assert p1.fight_zone == [{id1, card1}, {id3, card3}]

    assert {:ok, game} = Game.GenServer.play_card(pid, "p1", id2)
    p1 = KeyListUtils.find(game.players, "p1")

    assert [] = p1.hand
    assert p1.fight_zone == [{id1, card1}, {id3, card3}, {id2, card2}]
  end

  test "buying cards moves them to discard" do
    assert Cards.gems() != Cards.gems()
    gems = Cards.gems()

    [orc_grunt1, orc_grunt2] = Cards.with_id(:orc_grunt, 2)
    [arkus] = Cards.with_id(:arkus)
    [cult_priest1, cult_priest2] = Cards.with_id(:cult_priest, 2)
    [myros] = Cards.with_id(:myros)
    [filler] = Cards.with_id(:whatever)

    p1 = %{
      Player.empty()
      | gold: 8,
        discard: [myros]
    }

    p2 = Player.empty()

    game = %{
      Game.empty([{"p1", p1}, {"p2", p2}], "p1")
      | gems: gems,
        market: [orc_grunt1, arkus, orc_grunt2, filler, filler],
        market_deck: [cult_priest1],
        cemetery: [cult_priest2]
    }

    {:ok, pid} = Game.GenServer.start({:from_game, game})

    # not p2's turn
    assert Game.GenServer.buy_card(pid, "p2", elem(orc_grunt1, 0)) == :error
    # not in market
    assert Game.GenServer.buy_card(pid, "p1", elem(cult_priest1, 0)) == :error
    assert Game.GenServer.buy_card(pid, "p1", elem(cult_priest2, 0)) == :error

    # buying orc_grunt1
    assert {:ok, game} = Game.GenServer.buy_card(pid, "p1", elem(orc_grunt1, 0))
    p1 = KeyListUtils.find(game.players, "p1")
    assert p1.gold == 5
    assert p1.discard == [orc_grunt1, myros]
    assert game.market == [cult_priest1, arkus, orc_grunt2, filler, filler]
    assert game.market_deck == []

    # to expensive
    assert Game.GenServer.buy_card(pid, "p1", elem(arkus, 0)) == :error

    # buying orc_grunt2
    assert {:ok, game} = Game.GenServer.buy_card(pid, "p1", elem(orc_grunt2, 0))
    p1 = KeyListUtils.find(game.players, "p1")
    assert p1.gold == 2
    assert p1.discard == [orc_grunt2, orc_grunt1, myros]
    assert game.market == [cult_priest1, arkus, nil, filler, filler]
    assert game.market_deck == []

    # buying gem
    [gem | tail] = gems

    assert {:ok, game} = Game.GenServer.buy_card(pid, "p1", elem(gem, 0))

    p1 = KeyListUtils.find(game.players, "p1")

    assert p1.gold == 0
    assert p1.discard == [gem, orc_grunt2, orc_grunt1, myros]
    assert game.gems == tail
    assert game.market == [cult_priest1, arkus, nil, filler, filler]
    assert game.market_deck == []
  end

  test "attacking" do
    [tithe_priest] = Cards.with_id(:tithe_priest)
    [smash_and_grab] = Cards.with_id(:smash_and_grab)
    [orc_grunt] = Cards.with_id(:orc_grunt)
    [cult_priest] = Cards.with_id(:cult_priest)
    [street_thug] = Cards.with_id(:street_thug)

    p1 = %{
      Player.empty()
      | combat: 10,
        fight_zone: [tithe_priest]
    }

    p2 = %{Player.empty() | fight_zone: [cult_priest, orc_grunt, smash_and_grab, street_thug]}

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    {:ok, pid} = Game.GenServer.start({:from_game, game})

    # player doesn't exist
    assert Game.GenServer.attack(pid, "p1", "p3", :player) == :error
    # not p2's turn
    assert Game.GenServer.attack(pid, "p2", "p1", elem(orc_grunt, 0)) == :error
    # not in enemy fight zone
    assert Game.GenServer.attack(pid, "p1", "p2", elem(tithe_priest, 0)) == :error
    # can't attack self or own champion
    assert Game.GenServer.attack(pid, "p1", "p1", :player) == :error
    assert Game.GenServer.attack(pid, "p1", "p1", elem(tithe_priest, 0)) == :error
    # can't attack non-champion card
    assert Game.GenServer.attack(pid, "p1", "p2", elem(smash_and_grab, 0)) == :error
    # can't attack player or non-guard champion if there is a guard
    assert Game.GenServer.attack(pid, "p1", "p2", :player) == :error
    assert Game.GenServer.attack(pid, "p1", "p2", elem(cult_priest, 0)) == :error
    assert Game.GenServer.attack(pid, "p1", "p2", elem(street_thug, 0)) == :error

    # attack orc_grunt
    assert {:ok, game} = Game.GenServer.attack(pid, "p1", "p2", elem(orc_grunt, 0))

    p1 = %{p1 | combat: 7}

    p2 = %{
      p2
      | fight_zone: [cult_priest, smash_and_grab, street_thug],
        discard: [orc_grunt]
    }

    assert p1 == KeyListUtils.find(game.players, "p1")
    assert p2 == KeyListUtils.find(game.players, "p2")

    # attack street_thug
    assert {:ok, game} = Game.GenServer.attack(pid, "p1", "p2", elem(street_thug, 0))

    p1 = %{p1 | combat: 3}

    p2 = %{
      p2
      | fight_zone: [cult_priest, smash_and_grab],
        discard: [street_thug, orc_grunt]
    }

    assert p1 == KeyListUtils.find(game.players, "p1")
    assert p2 == KeyListUtils.find(game.players, "p2")

    # not enough combat for cult_priest
    assert Game.GenServer.attack(pid, "p1", "p2", elem(cult_priest, 0)) == :error

    # attack player directly
    assert {:ok, game} = Game.GenServer.attack(pid, "p1", "p2", :player)

    p1 = %{p1 | combat: 0}
    p2 = %{p2 | hp: 47}

    assert p1 == KeyListUtils.find(game.players, "p1")
    assert p2 == KeyListUtils.find(game.players, "p2")
  end

  test "attacking and killing a player" do
    p1 = %{Player.empty() | combat: 10}
    p2 = %{Player.empty() | hp: 8}

    game = %Game{
      players: [{"p1", p1}, {"p2", p2}],
      current_player: "p1",
      gems: [],
      market: [],
      market_deck: [],
      cemetery: []
    }

    {:ok, pid} = Game.GenServer.start({:from_game, game})

    assert {:victory, "p1", game} = Game.GenServer.attack(pid, "p1", "p2", :player)

    p1 = %{p1 | combat: 2}
    p2 = %{p2 | hp: 0}
    assert p1 == KeyListUtils.find(game.players, "p1")
    assert p2 == KeyListUtils.find(game.players, "p2")

    # can't attack dead player
    assert Game.GenServer.attack(pid, "p1", "p2", :player) == :error
  end

  test "attacking when no combat" do
    p1 = Player.empty()
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    {:ok, pid} = Game.GenServer.start({:from_game, game})

    assert Game.GenServer.attack(pid, "p1", "p2", :player) == :error
  end

  test "attacking when 4 players" do
    p1 = %{Player.empty() | combat: 3}
    p2 = Player.empty()
    p3 = Player.empty()
    p4 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}, {"p3", p3}, {"p4", p4}], "p1")

    {:ok, pid} = Game.GenServer.start({:from_game, game})

    assert Game.GenServer.attack(pid, "p1", "p3", :player) == :error
    assert {:ok, _} = Game.GenServer.attack(pid, "p1", "p4", :player)
  end

  test "end turn" do
    [orc_grunt] = Cards.with_id(:orc_grunt)
    [lys] = Cards.with_id(:lys)
    expended_lys = {elem(lys, 0), elem(lys, 1) |> Cards.Card.expend()}
    [arkus] = Cards.with_id(:arkus)
    [smash_and_grab] = Cards.with_id(:smash_and_grab)
    [cult_priest] = Cards.with_id(:cult_priest)
    [myros] = Cards.with_id(:myros)
    [gem1, gem2, gem3] = Cards.with_id(:gem, 3)

    p1 = %{Player.empty() | hp: 0}

    p2 = Player.empty()

    p3 = %{
      Player.empty()
      | gold: 1,
        combat: 3,
        hand: [arkus],
        deck: [orc_grunt, gem1],
        discard: [myros, gem2],
        fight_zone: [expended_lys, gem3, cult_priest, smash_and_grab]
    }

    game = Game.empty([{"p1", p1}, {"p2", p2}, {"p3", p3}], "p3")

    {:ok, pid} = Game.GenServer.start({:from_game, game})

    # not p1 or p2's turn
    assert Game.GenServer.discard_phase(pid, "p1") == :error
    assert Game.GenServer.discard_phase(pid, "p2") == :error

    assert {:ok, game} = Game.GenServer.discard_phase(pid, "p3")

    p3 = %{
      p3
      | gold: 0,
        combat: 0,
        hand: [],
        deck: [orc_grunt, gem1],
        discard: [arkus, smash_and_grab, gem3, myros, gem2],
        fight_zone: [lys, cult_priest]
    }

    assert p1 == KeyListUtils.find(game.players, "p1")
    assert p2 == KeyListUtils.find(game.players, "p2")
    assert p3 == KeyListUtils.find(game.players, "p3")

    assert game.current_player == "p3"

    assert Game.GenServer.draw_phase(pid, "p1") == :error
    assert Game.GenServer.draw_phase(pid, "p2") == :error

    assert {:ok, game} = Game.GenServer.draw_phase(pid, "p3")

    assert p1 == KeyListUtils.find(game.players, "p1")
    assert p2 == KeyListUtils.find(game.players, "p2")

    p3 = KeyListUtils.find(game.players, "p3")
    assert [^orc_grunt, ^gem1, hand3, hand4, hand5] = p3.hand
    assert [deck1, deck2] = p3.deck
    assert [] = p3.discard

    assert hand3 == arkus or
             hand3 == smash_and_grab or
             hand3 == gem3 or
             hand3 == myros or
             hand3 == gem2

    assert hand4 == arkus or
             hand4 == smash_and_grab or
             hand4 == gem3 or
             hand4 == myros or
             hand4 == gem2

    assert hand5 == arkus or
             hand5 == smash_and_grab or
             hand5 == gem3 or
             hand5 == myros or
             hand5 == gem2

    assert hand3 != hand4 and hand4 != hand5 and hand5 != hand3

    assert deck1 == arkus or
             deck1 == smash_and_grab or
             deck1 == gem3 or
             deck1 == myros or
             deck1 == gem2

    assert deck2 == arkus or
             deck2 == smash_and_grab or
             deck2 == gem3 or
             deck2 == myros or
             deck2 == gem2

    assert deck1 != deck2

    assert deck1 != hand3
    assert deck1 != hand4
    assert deck1 != hand5

    assert deck2 != hand3
    assert deck2 != hand4
    assert deck2 != hand5

    assert game.current_player == "p2"
  end

  test "current player doesn't exist" do
    p1 = Player.empty()
    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p3")

    {:ok, pid} = Game.GenServer.start({:from_game, game})

    assert Game.GenServer.attack(pid, "p3", "p2", :player) == :error
  end

  test "can't buy gem if no gold" do
    gems = Cards.gems()

    p1 = Player.empty()
    p2 = Player.empty()

    game = %{Game.empty([{"p1", p1}, {"p2", p2}], "p1") | gems: gems}

    {:ok, pid} = Game.GenServer.start({:from_game, game})

    assert Game.GenServer.buy_card(pid, "p1", gems |> hd() |> elem(0)) == :error
  end

  test "game end" do
    p1 = %{Player.empty() | hp: 4}
    p2 = %{Player.empty() | combat: 12}
    p3 = %{Player.empty() | hp: 6}

    game = Game.empty([{"p1", p1}, {"p2", p2}, {"p3", p3}], "p2")

    {:ok, pid} = Game.GenServer.start({:from_game, game})

    assert {:ok, _} = Game.GenServer.attack(pid, "p2", "p3", :player)

    assert {:victory, "p2", game} = Game.GenServer.attack(pid, "p2", "p1", :player)
    assert [{_, %{hp: 0}}, _, {_, %{hp: 0}}] = game.players
  end
end
