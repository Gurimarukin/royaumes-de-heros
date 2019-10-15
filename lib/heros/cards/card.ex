defmodule Heros.Cards.Card do
  defstruct name: nil,
            image: nil,
            is_champion: false

  alias Heros.Utils
  alias Heros.Cards.{Card, Decks}

  def random_id, do: UUID.uuid1(:hex)

  def hidden do
    %Card{image: "https://www.herorealms.com/wp-content/uploads/2017/09/hero_realms_back.jpg"}
  end

  def add_attack(game, amount), do: add_resource(game, :attack, amount)

  def add_gold(game, amount), do: add_resource(game, :gold, amount)

  def add_resource(game, resource, amount) do
    case game.match.current_player do
      nil ->
        game

      player_id ->
        update_in(game.match.players, fn players ->
          Utils.keyupdate(players, player_id, fn player ->
            update_in(player, [resource], &(&1 + amount))
          end)
        end)
    end
  end

  def stays_on_board(card) do
    case fetch(card) do
      nil -> false
      card -> card.is_champion
    end
  end

  def fetch(card) do
    try_apply(Decks.Base, :fetch, [card])
  end

  def primary_effect(game, card) do
    try_apply(Decks.Base, :primary_effect, [game, card])
  end

  defp try_apply(module, fun, args) do
    try do
      apply(module, fun, args)
    rescue
      e in FunctionClauseError ->
        args_length = length(args)

        case e do
          %FunctionClauseError{
            arity: ^args_length,
            function: ^fun,
            module: ^module
          } ->
            nil
        end
    end
  end
end
