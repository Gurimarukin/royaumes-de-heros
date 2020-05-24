defmodule Heros.Cards.Decks.Base do
  alias Heros.Cards
  alias Heros.Cards.Card

  @spec get :: list({Card.id(), Card.t()})
  def get do
    Cards.with_id(:shortsword) ++
      Cards.with_id(:dagger) ++
      Cards.with_id(:ruby) ++
      Cards.with_id(:gold, 7)
  end
end
