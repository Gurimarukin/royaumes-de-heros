defmodule Heros.Cards.Decks.Base do
  alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

  @spec get :: list({Card.id(), Card.t()})
  def get do
    Cards.with_id(:shortsword) ++
      Cards.with_id(:dagger) ++
      Cards.with_id(:ruby) ++
      Cards.with_id(:gold, 7)
  end

  @spec type(atom) :: nil | :item | :action | {:guard | :not_guard, integer}
  def type(:shortsword), do: :item
  def type(:dagger), do: :item
  def type(:ruby), do: :item
  def type(_), do: nil

  @spec primary_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def primary_ability(game, :shortsword, player_id), do: game |> Game.add_combat(player_id, 2)
  def primary_ability(game, :dagger, player_id), do: game |> Game.add_combat(player_id, 1)
  def primary_ability(game, :ruby, player_id), do: game |> Game.add_gold(player_id, 2)
  def primary_ability(_game, _, _player_id), do: nil
end
