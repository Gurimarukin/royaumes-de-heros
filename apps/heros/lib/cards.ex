defmodule Heros.Cards do
  alias Heros.Cards.Card

  @spec gems :: list({Card.id(), Card.t()})
  def gems do
    Card.with_id(:gem, 16)
  end
end
