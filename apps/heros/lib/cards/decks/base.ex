defmodule Heros.Cards.Decks.Base do
  alias Heros.Cards.Card

  @spec get :: list({Card.id(), Card.t()})
  def get do
    Card.with_id(:shortsword) ++
      Card.with_id(:dagger) ++
      Card.with_id(:ruby) ++
      Card.with_id(:gold, 7)
  end
end
