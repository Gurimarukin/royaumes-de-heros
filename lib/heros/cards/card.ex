defmodule Heros.Cards.Card do
  defstruct name: nil,
            image: nil,
            is_champion: false

  require Logger

  alias Heros.Utils
  alias Heros.Cards.{Card, Decks, Guilds, Imperials, Necros, Wilds}

  def with_id(card, n \\ 1), do: List.duplicate(card, n) |> Enum.map(&{random_id(), &1})

  defp random_id, do: UUID.uuid1(:hex)

  def hidden do
    %Card{image: "https://www.herorealms.com/wp-content/uploads/2017/09/hero_realms_back.jpg"}
  end

  def get_gems, do: with_id(:gem, 16)

  def get_market do
    (Guilds.get() ++ Imperials.get() ++ Necros.get() ++ Wilds.get())
    |> Enum.shuffle()
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

  def fetch(:gem) do
    %Card{
      name: "Gemme de feu",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-081-fire-gem.jpg"
    }
  end

  @cards_modules [Decks.Base, Guilds, Imperials, Necros, Wilds]

  def fetch(card) do
    Enum.find_value(@cards_modules, &try_apply(&1, :fetch, [card])) ||
      (
        Logger.warn(~s"tried to apply :fetch for card without success: #{inspect(card)}")
        nil
      )
  end

  def primary_effect(game, card) do
    Enum.find_value(@cards_modules, &try_apply(&1, :primary_effect, [game, card])) ||
      (
        Logger.warn(~s"tried to apply :primary_effect for card without success: #{inspect(card)}")
        nil
      )
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
