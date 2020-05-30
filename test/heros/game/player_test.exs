defmodule Heros.Game.PlayerTest do
  use ExUnit.Case

  alias Heros.Game.Player

  test "draw_cards" do
    player = %{Player.empty() | hand: [:card]}
    assert Player.draw_cards(player, 3) == player
  end
end
