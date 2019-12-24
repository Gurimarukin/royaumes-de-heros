defmodule Heros.GameTest do
  use ExUnit.Case, async: true

  alias Heros.Game

  test "creates game" do
    {:ok, pid} = Game.start_link([:a, :b])
    game = Game.get(pid)
    assert game.players == [:a, :b]
  end
end
