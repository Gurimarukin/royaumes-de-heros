defmodule Heros.GamesTest do
  use ExUnit.Case, async: true

  alias Heros.Games

  setup do
    games = start_supervised!(Games)
    %{games: games}
  end

  test "creates game", %{games: games} do
    assert Games.list(games) == []

    id = Games.create(games, [])
    assert {:ok, game} = Games.lookup(games, id)
    assert Process.alive?(game)
  end
end
