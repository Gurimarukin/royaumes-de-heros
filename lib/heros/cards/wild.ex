defmodule Heros.Cards.Wild do
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

  def fetch(card) do
    case fetch_bis(card) do
      nil -> nil
      card -> put_in(card.faction, :wild)
    end
  end

  defp fetch_bis(:broelyn) do
    %Card{
      name: "Broelyn, Tisseuse de Savoirs",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-061-broelyn-loreweaver.jpg",
      cost: 4,
      champion: {:not_guard, 6}
    }
  end

  defp fetch_bis(:cron) do
    %Card{
      name: "Cron, le Berserker",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-062-cron-the-berserker.jpg",
      cost: 6,
      champion: {:not_guard, 6}
    }
  end

  defp fetch_bis(:dire_wolf) do
    %Card{
      name: "Loup Terrifiant",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-063-dire-wolf.jpg",
      cost: 5,
      champion: {:guard, 5}
    }
  end

  defp fetch_bis(:elven_curse) do
    %Card{
      name: "Malédiction Elfique",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-064-elven-curse.jpg",
      cost: 3
    }
  end

  defp fetch_bis(:elven_gift) do
    %Card{
      name: "Don Elfique",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-066-elven-gift.jpg",
      cost: 2
    }
  end

  defp fetch_bis(:grak) do
    %Card{
      name: "Grak, Géant de la Tempête",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-069-grak-storm-giant.jpg",
      cost: 8,
      champion: {:guard, 7}
    }
  end

  defp fetch_bis(:natures_bounty) do
    %Card{
      name: "Don de la Nature",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-070-natures-bounty.jpg",
      cost: 4
    }
  end

  defp fetch_bis(:orc_grunt) do
    %Card{
      name: "Grognard Orque",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-071-orc-grunt.jpg",
      cost: 3,
      champion: {:guard, 3}
    }
  end

  defp fetch_bis(:rampage) do
    %Card{
      name: "Sauvagerie",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-073-rampage.jpg",
      cost: 6
    }
  end

  defp fetch_bis(:torgen) do
    %Card{
      name: "Torgen Brise-Pierre",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-074-torgen-rocksplitter.jpg",
      cost: 7,
      champion: {:guard, 7}
    }
  end

  defp fetch_bis(:spark) do
    %Card{
      name: "Étincelle",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-075-spark.jpg",
      cost: 1
    }
  end

  defp fetch_bis(:wolf_form) do
    %Card{
      name: "Forme de Loup",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-078-wolf-form.jpg",
      cost: 5
    }
  end

  defp fetch_bis(:wolfs_shaman) do
    %Card{
      name: "Chamane des Loups",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-079-wolf-shaman.jpg",
      cost: 2,
      champion: {:not_guard, 4}
    }
  end

  defp fetch_bis(_), do: nil

  # def primary_effect(game, :shortsword), do: Card.add_attack(game, 2)
end
