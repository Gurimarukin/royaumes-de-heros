defmodule Heros.GamesTest do
  use ExUnit.Case, async: true

  alias Heros.{Games, Game}

  setup do
    games = start_supervised!(Games)
    %{games: games}
  end

  test "creates game", %{games: games} do
    assert Games.list(games) == []

    id = Games.create(games, [:a, :b])
    assert {:ok, game} = Games.lookup(games, id)
    assert Process.alive?(game)

    game = Game.get(game)
    assert game.players == [:a, :b]
  end
end
