defmodule Heros.Cards.GuildTest do
  use ExUnit.Case, async: true

  # alias Heros.{Cards, Game, KeyListUtils, Player}
  alias Heros.Cards.Card

  test "rasmus" do
    assert Card.cost(:rasmus) == 4
    assert Card.type(:rasmus) == {:not_guard, 5}
    assert Card.faction(:rasmus) == :guild
    assert Card.is_champion(:rasmus)
    assert not Card.is_guard(:rasmus)
  end
end
