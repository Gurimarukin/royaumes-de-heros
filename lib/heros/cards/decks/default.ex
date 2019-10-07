defmodule Heros.Cards.Decks.Default do
  alias Heros.Cards.Card

  def get do
    [
      short_sword(),
      dagger(),
      rubis(),
      coin(),
      coin(),
      coin(),
      coin(),
      coin(),
      coin(),
      coin()
    ]
  end

  def shuffled, do: Enum.shuffle(get())

  defp short_sword do
    %Card{name: "Épée courte", effect: &Card.add_attack(&1, 2)}
  end

  defp dagger do
    %Card{name: "Dague", effect: &Card.add_attack(&1, 1)}
  end

  defp rubis do
    %Card{name: "Rubis", effect: &Card.add_gold(&1, 2)}
  end

  defp coin do
    %Card{name: "Coin", effect: &Card.add_gold(&1, 1)}
  end
end
