defmodule Heros.Cards.Card do
  defstruct name: nil,
            image: nil

  def add_attack(game, amount) do
    case game.match.current_player do
      nil ->
        game

      player_id ->
        update_in(
          game.match.players[player_id],
          fn player -> update_in(player.attack, &(&1 + amount)) end
        )
    end
  end

  def add_gold(game, amount) do
    case game.match.current_player do
      nil ->
        game

      player_id ->
        update_in(
          game.match.players[player_id],
          fn player -> update_in(player.gold, &(&1 + amount)) end
        )
    end
  end
end
