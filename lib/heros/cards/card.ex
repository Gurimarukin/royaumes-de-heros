defmodule Heros.Cards.Card do
  defstruct name: nil,
            image: nil

  alias Heros.Cards.{Card, Decks}

  def random_id, do: UUID.uuid1(:hex)

  def hidden do
    %Card{image: "https://www.herorealms.com/wp-content/uploads/2017/09/hero_realms_back.jpg"}
  end

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

  def fetch(card) do
    try_apply(Decks.Base, :fetch, [card])
  end

  defp try_apply(module, fun, args) do
    try do
      apply(module, fun, args)
    rescue
      _ -> nil
    end
  end
end
