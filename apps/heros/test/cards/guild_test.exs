defmodule Heros.Cards.GuildTest do
  use ExUnit.Case, async: true

  # alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

  test "rasmus" do
    assert Card.cost(:rasmus) == 4
    assert Card.type(:rasmus) == {:not_guard, 5}
    assert Card.faction(:rasmus) == :guild
    assert Card.champion?(:rasmus)
    assert not Card.guard?(:rasmus)
  end
end
