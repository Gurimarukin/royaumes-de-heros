defmodule Heros.Cards.Decks.Base do
  alias Heros.Cards.Card

  def get do
    [
      :shortsword,
      :dagger,
      :ruby,
      :gold,
      :gold,
      :gold,
      :gold,
      :gold,
      :gold,
      :gold
    ]
  end

  def shuffled, do: Enum.shuffle(get())

  def shortsword do
    %Card{
      name: "Épée courte",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-125-shortsword.jpg"
    }
  end

  def shortsword(game), do: Card.add_attack(game, 2)

  def dagger do
    %Card{
      name: "Dague",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-129-dagger.jpg"
    }
  end

  def dagger(game), do: Card.add_attack(game, 1)

  def ruby do
    %Card{
      name: "Rubis",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-133-ruby.jpg"
    }
  end

  def ruby(game), do: Card.add_gold(game, 2)

  def gold do
    %Card{
      name: "Or",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-097-gold.jpg"
    }
  end

  def gold(game), do: Card.add_gold(game, 1)
end
