defmodule HerosWeb.GameLive.MatchTest do
  use ExUnit.Case

  import HerosWeb.GameLive.Match, only: [sorted_players: 2]

  test "sorted_players empty list" do
    assert sorted_players([], 1) == []
  end

  test "sorted_players one element" do
    assert sorted_players([a: 1], :b) == [a: 1]
  end

  test "sorted_players three element, none with id" do
    assert sorted_players([a: 1, b: 2, c: 3], :d) == [a: 1, b: 2, c: 3]
  end

  test "sorted_players three element, first with id" do
    assert sorted_players([a: 1, b: 2, c: 3], :a) == [a: 1, b: 2, c: 3]
  end

  test "sorted_players four element, second with id" do
    assert sorted_players([a: 1, b: 2, c: 3, d: 4], :b) == [b: 2, c: 3, d: 4, a: 1]
  end

  test "sorted_players four element, last with id" do
    assert sorted_players([a: 1, b: 2, c: 3, d: 4], :d) == [d: 4, a: 1, b: 2, c: 3]
  end
end
