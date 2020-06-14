defmodule Heros.Game.Cards.Decks.Base do
  alias Heros.Game
  alias Heros.Game.{Cards, Player}
  alias Heros.Game.Cards.Card

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
  def type(:gold), do: :item
  def type(_), do: nil

  @spec primary_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def primary_ability(:shortsword) do
    fn game, player_id -> game |> Game.add_combat(player_id, 2) end
  end

  def primary_ability(:dagger) do
    fn game, player_id -> game |> Game.add_combat(player_id, 1) end
  end

  def primary_ability(:ruby) do
    fn game, player_id -> game |> Game.add_gold(player_id, 2) end
  end

  def primary_ability(:gold) do
    fn game, player_id -> game |> Game.add_gold(player_id, 1) end
  end

  def primary_ability(_), do: nil
end
