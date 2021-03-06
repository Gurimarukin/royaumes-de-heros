defmodule Heros.GameTest do
  use ExUnit.Case, async: true

  alias Heros.Game
  alias Heros.Game.{Cards, Player}

  test "creates game" do
    {:ok, game} = Game.init_from_players(["p1", "p2"])

    # players
    assert [{"p1", _}, {"p2", _}] = game.players

    assert length(Game.player(game, "p1").hand) == 3
    assert length(Game.player(game, "p2").hand) == 5

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
    assert length(game.market_deck) == length(Cards.market()) - 5

    # cemetery
    assert game.cemetery == []
  end

  test "creates 4 players game" do
    {:ok, game} = Game.init_from_players(["p1", "p2", "p3", "p4", "p5"])

    assert length(Game.player(game, "p1").hand) == 3
    assert length(Game.player(game, "p2").hand) == 4
    assert length(Game.player(game, "p3").hand) == 5
    assert length(Game.player(game, "p4").hand) == 5
    assert length(Game.player(game, "p5").hand) == 5
  end

  test "doesn't create game with invalid settings" do
    # not a list
    assert :error = Game.init_from_players(:pouet)
    # less than 2 elements
    assert :error = Game.init_from_players([:a])
  end

  test "playing cards moves them from hand to fight zone" do
    {:ok, game} = Game.init_from_players(["p1", "p2"])

    p1 = Game.player(game, "p1")
    p2 = Game.player(game, "p2")

    [{id, _}, _, _, _, _] = p2.hand

    # b can't play as he isn't current player
    assert Game.play_card(game, "p2", id) == :error
    # a can't play b's card
    assert Game.play_card(game, "p1", id) == :error

    [{id1, card1}, {id2, card2}, {id3, card3}] = p1.hand

    # player not found, he isn't current player
    assert Game.play_card(game, "p3", id1) == :error
    # card not found
    assert Game.play_card(game, "p1", "whatever") == :error

    assert {:ok, game} = Game.play_card(game, "p1", id1)

    p1 = Game.player(game, "p1")

    assert [{^id2, ^card2}, {^id3, ^card3}] = p1.hand
    assert p1.fight_zone == [{id1, card1}]

    assert Game.play_card(game, "p1", id1) == :error

    assert {:ok, game} = Game.play_card(game, "p1", id3)

    p1 = Game.player(game, "p1")

    assert [{^id2, ^card2}] = p1.hand
    assert p1.fight_zone == [{id1, card1}, {id3, card3}]

    assert {:ok, game} = Game.play_card(game, "p1", id2)

    p1 = Game.player(game, "p1")

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

    # not p2's turn
    assert Game.buy_card(game, "p2", elem(orc_grunt1, 0)) == :error
    # not in market
    assert Game.buy_card(game, "p1", elem(cult_priest1, 0)) == :error
    assert Game.buy_card(game, "p1", elem(cult_priest2, 0)) == :error

    # buying orc_grunt1
    assert {:ok, game} = Game.buy_card(game, "p1", elem(orc_grunt1, 0))

    p1 = Game.player(game, "p1")

    assert p1.gold == 5
    assert p1.discard == [orc_grunt1, myros]
    assert game.market == [cult_priest1, arkus, orc_grunt2, filler, filler]
    assert game.market_deck == []

    # to expensive
    assert Game.buy_card(game, "p1", elem(arkus, 0)) == :error

    # buying orc_grunt2
    assert {:ok, game} = Game.buy_card(game, "p1", elem(orc_grunt2, 0))

    p1 = Game.player(game, "p1")

    assert p1.gold == 2
    assert p1.discard == [orc_grunt2, orc_grunt1, myros]
    assert game.market == [cult_priest1, arkus, nil, filler, filler]
    assert game.market_deck == []

    # buying gem
    [gem | tail] = gems

    assert {:ok, game} = Game.buy_card(game, "p1", elem(gem, 0))

    p1 = Game.player(game, "p1")

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

    # player doesn't exist
    assert Game.attack(game, "p1", "p3", :player) == :error
    # not p2's turn
    assert Game.attack(game, "p2", "p1", elem(orc_grunt, 0)) == :error
    # not in enemy fight zone
    assert Game.attack(game, "p1", "p2", elem(tithe_priest, 0)) == :error
    # can't attack self or own champion
    assert Game.attack(game, "p1", "p1", :player) == :error
    assert Game.attack(game, "p1", "p1", elem(tithe_priest, 0)) == :error
    # can't attack non-champion card
    assert Game.attack(game, "p1", "p2", elem(smash_and_grab, 0)) == :error
    # can't attack player or non-guard champion if there is a guard
    assert Game.attack(game, "p1", "p2", :player) == :error
    assert Game.attack(game, "p1", "p2", elem(cult_priest, 0)) == :error
    assert Game.attack(game, "p1", "p2", elem(street_thug, 0)) == :error

    # attack orc_grunt
    assert {:ok, game} = Game.attack(game, "p1", "p2", elem(orc_grunt, 0))

    p1 = %{p1 | combat: 7}

    p2 = %{
      p2
      | fight_zone: [cult_priest, smash_and_grab, street_thug],
        discard: [orc_grunt]
    }

    assert p1 == Game.player(game, "p1")
    assert p2 == Game.player(game, "p2")

    # attack street_thug
    assert {:ok, game} = Game.attack(game, "p1", "p2", elem(street_thug, 0))

    p1 = %{p1 | combat: 3}

    p2 = %{
      p2
      | fight_zone: [cult_priest, smash_and_grab],
        discard: [street_thug, orc_grunt]
    }

    assert p1 == Game.player(game, "p1")
    assert p2 == Game.player(game, "p2")

    # not enough combat for cult_priest
    assert Game.attack(game, "p1", "p2", elem(cult_priest, 0)) == :error

    # attack player directly
    assert {:ok, game} = Game.attack(game, "p1", "p2", :player)

    p1 = %{p1 | combat: 0}
    p2 = %{p2 | hp: 47}

    assert p1 == Game.player(game, "p1")
    assert p2 == Game.player(game, "p2")
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

    assert {:victory, "p1", game} = Game.attack(game, "p1", "p2", :player)

    p1 = %{p1 | combat: 2}
    p2 = %{p2 | hp: 0}
    assert p1 == Game.player(game, "p1")
    assert p2 == Game.player(game, "p2")

    # can't attack dead player
    assert Game.attack(game, "p1", "p2", :player) == :error
  end

  test "attacking when no combat" do
    p1 = Player.empty()
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert Game.attack(game, "p1", "p2", :player) == :error
  end

  test "attacking when 4 players" do
    p1 = %{Player.empty() | combat: 3}
    p2 = Player.empty()
    p3 = Player.empty()
    p4 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}, {"p3", p3}, {"p4", p4}], "p1")

    assert Game.attack(game, "p1", "p3", :player) == :error
    assert {:ok, _} = Game.attack(game, "p1", "p4", :player)
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
      | pending_interactions: [awesome: "interaction"],
        gold: 1,
        combat: 3,
        hand: [arkus],
        deck: [orc_grunt, gem1, myros, gem2],
        discard: [],
        fight_zone: [expended_lys, gem3, cult_priest, smash_and_grab]
    }

    game = Game.empty([{"p1", p1}, {"p2", p2}, {"p3", p3}], "p3")

    # not p1 or p2's turn
    assert Game.discard_phase(game, "p1") == :error
    assert Game.discard_phase(game, "p2") == :error

    # can't draw card yet
    assert Game.draw_phase(game, "p3") == :error

    assert {:ok, game} = Game.discard_phase(game, "p3")

    # can't discard cards again
    assert Game.discard_phase(game, "p3") == :error

    # can't do anything else than calling draw_phase
    assert Game.use_expend_ability(game, "p3", elem(lys, 0)) == :error

    p3 = %Player{
      pending_interactions: [],
      temporary_effects: [],
      discard_phase_done: true,
      hp: 50,
      max_hp: 50,
      gold: 0,
      combat: 0,
      hand: [],
      deck: [orc_grunt, gem1, myros, gem2],
      discard: [arkus, smash_and_grab, gem3],
      fight_zone: [lys, cult_priest]
    }

    assert p1 == Game.player(game, "p1")
    assert p2 == Game.player(game, "p2")
    assert p3 == Game.player(game, "p3")

    assert game.current_player == "p3"

    assert Game.draw_phase(game, "p1") == :error
    assert Game.draw_phase(game, "p2") == :error

    assert {:ok, game} = Game.draw_phase(game, "p3")

    # can't draw cards again nor discard
    assert Game.discard_phase(game, "p3") == :error
    assert Game.draw_phase(game, "p3") == :error

    assert p1 == Game.player(game, "p1")
    assert p2 == Game.player(game, "p2")

    p3 = Game.player(game, "p3")

    assert p3.pending_interactions == []
    assert p3.discard_phase_done == false
    assert p3.hp == 50
    assert p3.max_hp == 50
    assert p3.gold == 0
    assert p3.combat == 0
    assert p3.fight_zone == [lys, cult_priest]

    assert [^orc_grunt, ^gem1, ^myros, ^gem2, hand5] = p3.hand
    assert [deck1, deck2] = p3.deck
    assert [] = p3.discard

    assert Enum.any?([arkus, smash_and_grab, gem3], &(&1 == hand5))
    assert Enum.any?([arkus, smash_and_grab, gem3], &(&1 == deck1))
    assert Enum.any?([arkus, smash_and_grab, gem3], &(&1 == deck2))

    assert deck1 != deck2
    assert deck1 != hand5
    assert deck2 != hand5

    assert game.current_player == "p2"
  end

  test "current player doesn't exist" do
    p1 = Player.empty()
    p2 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}], "p3")

    assert Game.attack(game, "p3", "p2", :player) == :error
  end

  test "can't buy gem if no gold" do
    gems = Cards.gems()

    p1 = Player.empty()
    p2 = Player.empty()

    game = %{Game.empty([{"p1", p1}, {"p2", p2}], "p1") | gems: gems}

    assert Game.buy_card(game, "p1", gems |> hd() |> elem(0)) == :error
  end

  test "player die" do
    [tithe_priest] = Cards.with_id(:tithe_priest)
    [dagger] = Cards.with_id(:dagger)
    [gem] = Cards.with_id(:gem)
    [arkus] = Cards.with_id(:arkus)
    [gold] = Cards.with_id(:gold)

    p1 = %{
      Player.empty()
      | hp: 4,
        deck: [arkus],
        hand: [dagger],
        fight_zone: [gem, tithe_priest],
        discard: [gold]
    }

    p2 = %{Player.empty() | combat: 12}
    p3 = %{Player.empty() | hp: 6}

    game = Game.empty([{"p1", p1}, {"p2", p2}, {"p3", p3}], "p2")

    assert {:ok, game} = Game.attack(game, "p2", "p3", :player)
    assert {:victory, "p2", game} = Game.attack(game, "p2", "p1", :player)

    assert [
             {"p1",
              %{
                hp: 0,
                discard: [^gold, ^dagger, ^gem, ^tithe_priest, ^arkus],
                deck: [],
                hand: [],
                fight_zone: []
              }},
             {"p2", %{hp: 50}},
             {"p3", %{hp: 0}}
           ] = game.players
  end

  test "pending interactions" do
    [cron] = Cards.with_id(:cron)
    [arkus] = Cards.with_id(:arkus)
    [weyan] = Cards.with_id(:weyan)
    [gem] = Cards.with_id(:gem)

    p1 = %{
      Player.empty()
      | pending_interactions: [
          select_effect: [add_combat: 1, heal: 2],
          discard_card: nil
        ],
        gold: 20,
        combat: 10,
        hp: 10,
        hand: [gem],
        fight_zone: [arkus, weyan]
    }

    p2 = Player.empty()

    game_init = %{
      Game.empty([{"p1", p1}, {"p2", p2}], "p1")
      | market: [cron]
    }

    game = game_init

    # you have to interact, main phase actions aren't possible
    assert Game.play_card(game, "p1", elem(gem, 0)) == :error
    assert Game.use_expend_ability(game, "p1", elem(arkus, 0)) == :error
    assert Game.use_ally_ability(game, "p1", elem(arkus, 0)) == :error
    assert Game.buy_card(game, "p1", elem(cron, 0)) == :error
    assert Game.attack(game, "p1", "p2", :player) == :error

    # and you can't draw phase
    assert Game.draw_phase(game, "p1") == :error

    # but you can end your turn (discard_phase)
    # and it resets the pending interactions
    assert {:ok, game} = Game.discard_phase(game, "p1")
    assert Game.player(game, "p1").pending_interactions == []

    # consuming interactions
    game = game_init

    assert {:ok, game} = Game.interact(game, "p1", {:select_effect, 1})

    p1 = Game.player(game, "p1")

    assert p1.hp == 12
    assert p1.pending_interactions == [discard_card: nil]

    assert Game.interact(game, "p1", {:select_effect, 1}) == :error
    assert Game.interact(game, "p1", {:discard_card, elem(gem, 0)}) == :error
  end

  test "surrender" do
    [tithe_priest] = Cards.with_id(:tithe_priest)
    [dagger] = Cards.with_id(:dagger)
    [gem] = Cards.with_id(:gem)
    [arkus] = Cards.with_id(:arkus)
    [gold] = Cards.with_id(:gold)

    p1 = %{
      Player.empty()
      | deck: [tithe_priest],
        hand: [dagger],
        fight_zone: [gem, arkus],
        discard: [gold]
    }

    p2 = Player.empty()
    p3 = Player.empty()

    game = Game.empty([{"p1", p1}, {"p2", p2}, {"p3", p3}], "p1")

    assert game.current_player == "p1"

    assert {:ok, game} = Game.surrender(game, "p1")

    assert game.current_player == "p2"

    assert [
             {"p1",
              %{
                hp: 0,
                discard: [^gold, ^dagger, ^gem, ^arkus, ^tithe_priest],
                deck: [],
                hand: [],
                fight_zone: []
              }},
             {"p2", %{hp: 50}},
             {"p3", %{hp: 50}}
           ] = game.players

    assert :error = Game.surrender(game, "p1")

    assert {:victory, "p2", game} = Game.surrender(game, "p3")

    assert [{"p1", %{hp: 0}}, {"p2", %{hp: 50}}, {"p3", %{hp: 0}}] = game.players

    assert :error = Game.surrender(game, "p2")
  end
end
