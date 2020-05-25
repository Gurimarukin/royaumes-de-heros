defmodule Heros.PlayerTest do
  use ExUnit.Case

  alias Heros.Player

  test "draw_cards" do
    player = %{Player.empty() | hand: [:card]}
    assert Player.draw_cards(player, 3) == player
  end
end
