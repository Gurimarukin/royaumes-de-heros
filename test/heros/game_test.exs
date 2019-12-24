defmodule Heros.GameTest do
  use ExUnit.Case, async: true

  alias Heros.Game
  alias Heros.Game.Player

  test "creates game" do
    {:ok, pid} = Game.start_link([:a, :b])
    game = Game.get(pid)
    assert game.players == [{:a, %Player{}}, {:b, %Player{}}]

    assert game.current_player == nil
  end

  test "checks game settings" do
    assert {:error, :invalid_players_number} = Game.start_link([:a])
    assert {:error, :invalid_players_number} = Game.start_link([:a, :b, :c])
  end
end
