defmodule Heros.GameTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, Player, Utils}

  test "creates game" do
    {:ok, pid} = Game.start({:from_player_ids, ["p1", "p2"]})
    game = Game.get(pid)

    # players
    assert [{"p1", _}, {"p2", _}] = game.players

    assert length(Utils.keyfind(game.players, "p1").hand) == 3
    assert length(Utils.keyfind(game.players, "p2").hand) == 5

    game.players
    |> Enum.map(fn {_, player} ->
      assert player.hp == 50
      assert player.max_hp == 50
      assert player.gold == 0
      assert player.attack == 0

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
    {:ok, pid} = Game.start({:from_player_ids, ["p1", "p2", "p3", "p4"]})
    game = Game.get(pid)

    assert length(Utils.keyfind(game.players, "p1").hand) == 3
    assert length(Utils.keyfind(game.players, "p2").hand) == 4
    assert length(Utils.keyfind(game.players, "p3").hand) == 5
    assert length(Utils.keyfind(game.players, "p4").hand) == 5
  end

  test "doesn't create game with invalid settings" do
    assert {:error, :invalid_players} = Game.start({:from_player_ids, :pouet})
    assert {:error, :invalid_players_number} = Game.start({:from_player_ids, [:a]})

    assert {:error, :invalid_players_number} =
             Game.start({:from_player_ids, [:a, :b, :c, :d, :e]})
  end

  test "playing cards moves them from hand to fight zone" do
    {:ok, pid} = Game.start({:from_player_ids, ["p1", "p2"]})
    game = Game.get(pid)
    p1 = Utils.keyfind(game.players, "p1")
    p2 = Utils.keyfind(game.players, "p2")

    [{id, _}, _, _, _, _] = p2.hand
    # b can't play as he isn't current player
    assert Game.play_card(pid, "p2", id) == :forbidden
    # a can't play b's card
    assert Game.play_card(pid, "p1", id) == :not_found

    [{id1, card1}, {id2, card2}, {id3, card3}] = p1.hand

    # player not found, he isn't current player
    assert Game.play_card(pid, "p3", id1) == :forbidden
    # card not found
    assert Game.play_card(pid, "p1", "whatever") == :not_found

    assert Game.play_card(pid, "p1", id1) == :ok
    game = Game.get(pid)
    p1 = Utils.keyfind(game.players, "p1")

    assert [{^id2, ^card2}, {^id3, ^card3}] = p1.hand
    assert p1.fight_zone == [{id1, card1}]

    assert Game.play_card(pid, "p1", id1) == :not_found

    assert Game.play_card(pid, "p1", id3) == :ok
    game = Game.get(pid)
    p1 = Utils.keyfind(game.players, "p1")

    assert [{^id2, ^card2}] = p1.hand
    assert p1.fight_zone == [{id1, card1}, {id3, card3}]

    assert Game.play_card(pid, "p1", id2) == :ok
    game = Game.get(pid)
    p1 = Utils.keyfind(game.players, "p1")

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

    p1 = %Player{
      hp: 50,
      max_hp: 50,
      gold: 8,
      attack: 0,
      hand: [],
      deck: [],
      discard: [myros],
      fight_zone: []
    }

    p2 = %Player{
      hp: 50,
      max_hp: 50,
      gold: 0,
      attack: 0,
      hand: [],
      deck: [],
      discard: [],
      fight_zone: []
    }

    game = %Game{
      players: [{"p1", p1}, {"p2", p2}],
      current_player: "p1",
      gems: gems,
      market: [orc_grunt1, arkus, orc_grunt2, filler, filler],
      market_deck: [cult_priest1],
      cemetery: [cult_priest2]
    }

    {:ok, pid} = Game.start({:from_game, game})

    # not p2's turn
    assert Game.buy_card(pid, "p2", elem(orc_grunt1, 0)) == :forbidden
    # not in market
    assert Game.buy_card(pid, "p1", elem(cult_priest1, 0)) == :not_found
    assert Game.buy_card(pid, "p1", elem(cult_priest2, 0)) == :not_found

    # buying orc_grunt1
    assert Game.buy_card(pid, "p1", elem(orc_grunt1, 0)) == :ok
    game = Game.get(pid)
    p1 = Utils.keyfind(game.players, "p1")
    assert p1.gold == 5
    assert p1.discard == [orc_grunt1, myros]
    assert game.market == [cult_priest1, arkus, orc_grunt2, filler, filler]
    assert game.market_deck == []

    # to expensive
    assert Game.buy_card(pid, "p1", elem(arkus, 0)) == :forbidden

    # buying orc_grunt2
    assert Game.buy_card(pid, "p1", elem(orc_grunt2, 0)) == :ok
    game = Game.get(pid)
    p1 = Utils.keyfind(game.players, "p1")
    assert p1.gold == 2
    assert p1.discard == [orc_grunt2, orc_grunt1, myros]
    assert game.market == [cult_priest1, arkus, nil, filler, filler]
    assert game.market_deck == []

    # buying gem
    [gem | tail] = gems
    assert Game.buy_card(pid, "p1", elem(gem, 0)) == :ok
    game = Game.get(pid)
    p1 = Utils.keyfind(game.players, "p1")
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

    p1 =
      Player.empty()
      |> put_in([:attack], 10)
      |> put_in([:fight_zone], [tithe_priest])

    p2 = put_in(Player.empty().fight_zone, [cult_priest, orc_grunt, smash_and_grab, street_thug])

    game = %Game{
      players: [{"p1", p1}, {"p2", p2}],
      current_player: "p1",
      gems: [],
      market: [],
      market_deck: [],
      cemetery: []
    }

    {:ok, pid} = Game.start({:from_game, game})

    # player doesn't exist
    assert Game.attack(pid, "p1", "p3", :player) == :not_found
    # not p2's turn
    assert Game.attack(pid, "p2", "p1", elem(orc_grunt, 0)) == :forbidden
    # not in enemy fight zone
    assert Game.attack(pid, "p1", "p2", elem(tithe_priest, 0)) == :not_found
    # can't attack self or own champion
    assert Game.attack(pid, "p1", "p1", :player) == :forbidden
    assert Game.attack(pid, "p1", "p1", elem(tithe_priest, 0)) == :forbidden
    # can't attack non-champion card
    assert Game.attack(pid, "p1", "p2", elem(smash_and_grab, 0)) == :forbidden
    # can't attack player or non-guard champion if there is a guard
    assert Game.attack(pid, "p1", "p2", :player) == :forbidden
    assert Game.attack(pid, "p1", "p2", elem(cult_priest, 0)) == :forbidden
    assert Game.attack(pid, "p1", "p2", elem(street_thug, 0)) == :forbidden

    # attack orc_grunt
    assert Game.attack(pid, "p1", "p2", elem(orc_grunt, 0)) == :ok
    game = Game.get(pid)
    p1 = put_in(p1.attack, 7)

    p2 =
      p2
      |> put_in([:fight_zone], [cult_priest, smash_and_grab, street_thug])
      |> put_in([:discard], [orc_grunt])

    assert p1 == Utils.keyfind(game.players, "p1")
    assert p2 == Utils.keyfind(game.players, "p2")

    # attack street_thug
    assert Game.attack(pid, "p1", "p2", elem(street_thug, 0)) == :ok
    game = Game.get(pid)
    p1 = put_in(p1.attack, 3)

    p2 =
      p2
      |> put_in([:fight_zone], [cult_priest, smash_and_grab])
      |> put_in([:discard], [street_thug, orc_grunt])

    assert p1 == Utils.keyfind(game.players, "p1")
    assert p2 == Utils.keyfind(game.players, "p2")

    # not enough attack for cult_priest
    assert Game.attack(pid, "p1", "p2", elem(cult_priest, 0)) == :forbidden

    # attack player directly
    assert Game.attack(pid, "p1", "p2", :player) == :ok
    game = Game.get(pid)
    p1 = put_in(p1.attack, 0)
    p2 = put_in(p2.hp, 47)
    assert p1 == Utils.keyfind(game.players, "p1")
    assert p2 == Utils.keyfind(game.players, "p2")
  end

  test "attacking and killing a player" do
    p1 = put_in(Player.empty().attack, 10)
    p2 = put_in(Player.empty().hp, 8)

    game = %Game{
      players: [{"p1", p1}, {"p2", p2}],
      current_player: "p1",
      gems: [],
      market: [],
      market_deck: [],
      cemetery: []
    }

    {:ok, pid} = Game.start({:from_game, game})

    assert Game.attack(pid, "p1", "p2", :player) == :ok
    game = Game.get(pid)
    p1 = put_in(p1.attack, 2)
    p2 = put_in(p2.hp, 0)
    assert p1 == Utils.keyfind(game.players, "p1")
    assert p2 == Utils.keyfind(game.players, "p2")

    # can't attack dead player
    assert Game.attack(pid, "p1", "p2", :player) == :forbidden
  end

  test "attacking when no attack" do
    p1 = Player.empty()
    p2 = Player.empty()

    game = %Game{
      players: [{"p1", p1}, {"p2", p2}],
      current_player: "p1",
      gems: [],
      market: [],
      market_deck: [],
      cemetery: []
    }

    {:ok, pid} = Game.start({:from_game, game})

    assert Game.attack(pid, "p1", "p2", :player) == :forbidden
  end

  test "attacking when 4 players" do
    p1 = put_in(Player.empty().attack, 3)
    p2 = Player.empty()
    p3 = Player.empty()
    p4 = Player.empty()

    game = %Game{
      players: [{"p1", p1}, {"p2", p2}, {"p3", p3}, {"p4", p4}],
      current_player: "p1",
      gems: [],
      market: [],
      market_deck: [],
      cemetery: []
    }

    {:ok, pid} = Game.start({:from_game, game})

    assert Game.attack(pid, "p1", "p3", :player) == :forbidden
    assert Game.attack(pid, "p1", "p4", :player) == :ok
  end
end
