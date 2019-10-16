defmodule Heros.Cards.Decks.Base do
  alias Heros.Cards.Card

  def get do
    Card.with_id(:shortsword) ++
      Card.with_id(:dagger) ++
      Card.with_id(:ruby) ++
      Card.with_id(:gold, 7)
  end

  def shuffled, do: Enum.shuffle(get())

  def fetch(:shortsword) do
    %Card{
      name: "Épée courte",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-125-shortsword.jpg"
    }
  end

  def fetch(:dagger) do
    %Card{
      name: "Dague",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-129-dagger.jpg"
    }
  end

  def fetch(:ruby) do
    %Card{
      name: "Rubis",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-133-ruby.jpg"
    }
  end

  def fetch(:gold) do
    %Card{
      name: "Or",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-097-gold.jpg"
    }
  end

  def primary_effect(game, :shortsword), do: Card.add_attack(game, 2)

  def primary_effect(game, :dagger), do: Card.add_attack(game, 1)

  def primary_effect(game, :ruby), do: Card.add_gold(game, 2)

  def primary_effect(game, :gold), do: Card.add_gold(game, 1)
end
