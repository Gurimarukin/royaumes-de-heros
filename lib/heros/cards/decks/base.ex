defmodule Heros.Cards.Decks.Base do
  alias Heros.Cards.Card

  def get do
    [
      {Card.random_id(), :shortsword},
      {Card.random_id(), :dagger},
      {Card.random_id(), :ruby},
      {Card.random_id(), :gold},
      {Card.random_id(), :gold},
      {Card.random_id(), :gold},
      {Card.random_id(), :gold},
      {Card.random_id(), :gold},
      {Card.random_id(), :gold},
      {Card.random_id(), :gold}
    ]
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

  def effect(:shortsword, game), do: Card.add_attack(game, 2)

  def effect(:dagger, game), do: Card.add_attack(game, 1)

  def effect(:ruby, game), do: Card.add_gold(game, 2)

  def effect(:gold, game), do: Card.add_gold(game, 1)
end
