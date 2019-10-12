defmodule Heros.Cards.Card do
  defstruct name: nil,
            image: nil

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
        {^player_id, player} = List.keyfind(game.match.players, player_id, 0)
        player = update_in(player, [resource], &(&1 + amount))
        players = List.keyreplace(game.match.players, player_id, 0, {player_id, player})
        put_in(game.match.players, players)
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
