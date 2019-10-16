defmodule Heros.Game.PlayerTest do
  use ExUnit.Case

  alias Heros.Game.Player

  test "Player.sorted empty list" do
    assert Player.sorted([], 1) == {nil, []}
  end

  test "Player.sorted one element" do
    assert Player.sorted([a: 1], :a) == {{:a, 1}, []}
  end

  test "Player.sorted one element, none with id" do
    assert Player.sorted([a: 1], :b) == {nil, [a: 1]}
  end

  test "Player.sorted three element, none with id" do
    assert Player.sorted([a: 1, b: 2, c: 3], :d) == {nil, [a: 1, b: 2, c: 3]}
  end

  test "Player.sorted three element, first with id" do
    assert Player.sorted([a: 1, b: 2, c: 3], :a) == {{:a, 1}, [b: 2, c: 3]}
  end

  test "Player.sorted four element, second with id" do
    assert Player.sorted([a: 1, b: 2, c: 3, d: 4], :b) == {{:b, 2}, [c: 3, d: 4, a: 1]}
  end

  test "Player.sorted four element, last with id" do
    assert Player.sorted([a: 1, b: 2, c: 3, d: 4], :d) == {{:d, 4}, [a: 1, b: 2, c: 3]}
  end
end
