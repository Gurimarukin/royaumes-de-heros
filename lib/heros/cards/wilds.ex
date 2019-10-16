defmodule Heros.Cards.Wilds do
  alias Heros.Cards.Card

  def get do
    Card.with_id(:broelyn) ++
      Card.with_id(:cron) ++
      Card.with_id(:dire_wolf) ++
      Card.with_id(:elven_curse, 2) ++
      Card.with_id(:elven_gift, 3) ++
      Card.with_id(:grak) ++
      Card.with_id(:natures_bounty) ++
      Card.with_id(:orc_grunt, 2) ++
      Card.with_id(:rampage) ++
      Card.with_id(:torgen) ++
      Card.with_id(:spark, 3) ++
      Card.with_id(:wolf_form) ++
      Card.with_id(:wolfs_shaman, 2)
  end

  def fetch(:broelyn) do
    %Card{
      name: "Broelyn, Tisseuse de Savoirs",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-061-broelyn-loreweaver.jpg"
    }
  end

  def fetch(:cron) do
    %Card{
      name: "Cron, le Berserker",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-062-cron-the-berserker.jpg"
    }
  end

  def fetch(:dire_wolf) do
    %Card{
      name: "Loup Terrifiant",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-063-dire-wolf.jpg"
    }
  end

  def fetch(:elven_curse) do
    %Card{
      name: "Malédiction Elfique",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-064-elven-curse.jpg"
    }
  end

  def fetch(:elven_gift) do
    %Card{
      name: "Don Elfique",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-066-elven-gift.jpg"
    }
  end

  def fetch(:grak) do
    %Card{
      name: "Grak, Géant de la Tempête",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-069-grak-storm-giant.jpg"
    }
  end

  def fetch(:natures_bounty) do
    %Card{
      name: "Don de la Nature",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-070-natures-bounty.jpg"
    }
  end

  def fetch(:orc_grunt) do
    %Card{
      name: "Grognard Orque",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-071-orc-grunt.jpg"
    }
  end

  def fetch(:rampage) do
    %Card{
      name: "Sauvagerie",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-073-rampage.jpg"
    }
  end

  def fetch(:torgen) do
    %Card{
      name: "Torgen Brise-Pierre",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-074-torgen-rocksplitter.jpg"
    }
  end

  def fetch(:spark) do
    %Card{
      name: "Étincelle",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-075-spark.jpg"
    }
  end

  def fetch(:wolf_form) do
    %Card{
      name: "Forme de Loup",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-078-wolf-form.jpg"
    }
  end

  def fetch(:wolfs_shaman) do
    %Card{
      name: "Chamane des Loups",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-079-wolf-shaman.jpg"
    }
  end

  # def primary_effect(game, :shortsword), do: Card.add_attack(game, 2)
end
