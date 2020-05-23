defmodule HerosTest do
  use ExUnit.Case
  doctest Heros

  test "greets the world" do
    assert Heros.hello() == :world
  end
end
