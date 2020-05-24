defmodule Heros.GameTest do
  use ExUnit.Case, async: true

  alias Heros.Game

  test "creates game" do
    {:ok, pid} = Game.start([:a, :b])
    game = Game.get(pid)

    # players
    assert [{:a, _}, {:b, _}] = game.players

    assert length(game.players[:a].hand) == 3
    assert length(game.players[:b].hand) == 5

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
    assert game.current_player == :a

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
    {:ok, pid} = Game.start([:a, :b, :c, :d])
    game = Game.get(pid)

    assert length(game.players[:a].hand) == 3
    assert length(game.players[:b].hand) == 4
    assert length(game.players[:c].hand) == 5
    assert length(game.players[:d].hand) == 5
  end

  test "doesn't create game with invalid settings" do
    assert {:error, :invalid_players} = Game.start(:pouet)
    assert {:error, :invalid_players_number} = Game.start([:a])
    assert {:error, :invalid_players_number} = Game.start([:a, :b, :c, :d, :e])
  end
end
