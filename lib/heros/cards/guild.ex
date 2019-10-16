defmodule Heros.Cards.Guild do
  alias Heros.Cards.Card

  def get do
    Card.with_id(:borg) ++
      Card.with_id(:bribe, 3) ++
      Card.with_id(:death_threat) ++
      Card.with_id(:deception) ++
      Card.with_id(:fire_bomb) ++
      Card.with_id(:hit_job) ++
      Card.with_id(:intimidation, 2) ++
      Card.with_id(:myros) ++
      Card.with_id(:parov) ++
      Card.with_id(:profit, 3) ++
      Card.with_id(:rake) ++
      Card.with_id(:rasmus) ++
      Card.with_id(:smash_and_grab) ++
      Card.with_id(:street_thug, 2)
  end

  def fetch(card) do
    case fetch_bis(card) do
      nil -> nil
      card -> put_in(card.faction, :guild)
    end
  end

  defp fetch_bis(:borg) do
    %Card{
      name: "Borg, Mercenaire Ogre",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-021-borg-ogre-mercenary.jpg",
      cost: 6,
      champion: {:guard, 6}
    }
  end

  defp fetch_bis(:bribe) do
    %Card{
      name: "Pot-de-vin",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-022-bribe.jpg",
      cost: 3
    }
  end

  defp fetch_bis(:death_threat) do
    %Card{
      name: "Menace de Mort",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-025-death-threat.jpg",
      cost: 3
    }
  end

  defp fetch_bis(:deception) do
    %Card{
      name: "Duperie",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-026-deception.jpg",
      cost: 5
    }
  end

  defp fetch_bis(:fire_bomb) do
    %Card{
      name: "Bombe Incendiaire",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-027-fire-bomb.jpg",
      cost: 8
    }
  end

  defp fetch_bis(:hit_job) do
    %Card{
      name: "Assassinat",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-028-hit-job.jpg",
      cost: 4
    }
  end

  defp fetch_bis(:intimidation) do
    %Card{
      name: "Intimidation",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-029-intimidation.jpg",
      cost: 2
    }
  end

  defp fetch_bis(:myros) do
    %Card{
      name: "Myros, Mage de la Guilde",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-031-myros-guild-mage.jpg",
      cost: 5,
      champion: {:guard, 3}
    }
  end

  defp fetch_bis(:parov) do
    %Card{
      name: "Parov, l'Executeur",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-032-parov-the-enforcer.jpg",
      cost: 5,
      champion: {:guard, 5}
    }
  end

  defp fetch_bis(:profit) do
    %Card{
      name: "Bénéfice",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-033-profit.jpg",
      cost: 1
    }
  end

  defp fetch_bis(:rake) do
    %Card{
      name: "Rake, Maître Assassin",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-036-rake-master-assassin.jpg",
      cost: 7,
      champion: {:not_guard, 7}
    }
  end

  defp fetch_bis(:rasmus) do
    %Card{
      name: "Rasmus, le Contrebandier",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-037-rasmus-the-smuggler.jpg",
      cost: 4,
      champion: {:not_guard, 5}
    }
  end

  defp fetch_bis(:smash_and_grab) do
    %Card{
      name: "Casser et Piller",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-038-smash-and-grab.jpg",
      cost: 6
    }
  end

  defp fetch_bis(:street_thug) do
    %Card{
      name: "Bandit des Rues",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-039-street-thug.jpg",
      cost: 3,
      champion: {:not_guard, 4}
    }
  end

  defp fetch_bis(_), do: nil

  # def primary_effect(game, :shortsword), do: Card.add_attack(game, 2)
end
