defmodule Heros.Cards.Decks.Base do
  alias Heros.Cards.Card

  def get do
    [
      shortsword(),
      dagger(),
      ruby(),
      gold(),
      gold(),
      gold(),
      gold(),
      gold(),
      gold(),
      gold()
    ]
  end

  def shuffled, do: Enum.shuffle(get())

  defp shortsword do
    %Card{
      name: "Épée courte",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-125-shortsword.jpg",
      effect: &Card.add_attack(&1, 2)
    }
  end

  defp dagger do
    %Card{
      name: "Dague",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-129-dagger.jpg",
      effect: &Card.add_attack(&1, 1)
    }
  end

  defp ruby do
    %Card{
      name: "Rubis",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-133-ruby.jpg",
      effect: &Card.add_gold(&1, 2)
    }
  end

  defp gold do
    %Card{
      name: "Or",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-097-gold.jpg",
      effect: &Card.add_gold(&1, 1)
    }
  end
end
