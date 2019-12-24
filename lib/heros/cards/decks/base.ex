defmodule Heros.Cards.Decks.Base do
  alias Heros.Cards.Card

  def shuffled, do: Enum.shuffle(get())

  defp get do
    Card.with_id(nil, shortsword()) ++
      Card.with_id(nil, dagger()) ++
      Card.with_id(nil, ruby()) ++
      Card.with_id(nil, gold(), 7)
  end

  defp shortsword,
    do: %Card{
      name: "Épée courte",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-125-shortsword.jpg",
      primary_ability: fn game -> Card.add_attack(game, 2) end
    }

  defp dagger,
    do: %Card{
      name: "Dague",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-129-dagger.jpg",
      primary_ability: fn game -> Card.add_attack(game, 1) end
    }

  defp ruby,
    do: %Card{
      name: "Rubis",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-133-ruby.jpg",
      primary_ability: fn game -> Card.add_gold(game, 2) end
    }

  defp gold,
    do: %Card{
      name: "Or",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-097-gold.jpg",
      primary_ability: fn game -> Card.add_gold(game, 1) end
    }
end
