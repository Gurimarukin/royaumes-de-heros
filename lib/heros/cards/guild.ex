defmodule Heros.Cards.Guild do
  alias Heros.Cards.Card

  def get do
    (Card.with_id(borg()) ++
       Card.with_id(bribe(), 3) ++
       Card.with_id(death_threat()) ++
       Card.with_id(deception()) ++
       Card.with_id(fire_bomb()) ++
       Card.with_id(hit_job()) ++
       Card.with_id(intimidation(), 2) ++
       Card.with_id(myros()) ++
       Card.with_id(parov()) ++
       Card.with_id(profit(), 3) ++
       Card.with_id(rake()) ++
       Card.with_id(rasmus()) ++
       Card.with_id(smash_and_grab()) ++
       Card.with_id(street_thug(), 2))
    |> Enum.map(&put_in(&1.faction, :guild))
  end

  defp borg,
    do: %Card{
      name: "Borg, Mercenaire Ogre",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-021-borg-ogre-mercenary.jpg",
      cost: 6,
      champion: {:guard, 6}
    }

  defp bribe,
    do: %Card{
      name: "Pot-de-vin",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-022-bribe.jpg",
      cost: 3
    }

  defp death_threat,
    do: %Card{
      name: "Menace de Mort",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-025-death-threat.jpg",
      cost: 3
    }

  defp deception,
    do: %Card{
      name: "Duperie",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-026-deception.jpg",
      cost: 5
    }

  defp fire_bomb,
    do: %Card{
      name: "Bombe Incendiaire",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-027-fire-bomb.jpg",
      cost: 8
    }

  defp hit_job,
    do: %Card{
      name: "Assassinat",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-028-hit-job.jpg",
      cost: 4
    }

  defp intimidation,
    do: %Card{
      name: "Intimidation",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-029-intimidation.jpg",
      cost: 2
    }

  defp myros,
    do: %Card{
      name: "Myros, Mage de la Guilde",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-031-myros-guild-mage.jpg",
      cost: 5,
      champion: {:guard, 3}
    }

  defp parov,
    do: %Card{
      name: "Parov, l'Executeur",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-032-parov-the-enforcer.jpg",
      cost: 5,
      champion: {:guard, 5}
    }

  defp profit,
    do: %Card{
      name: "Bénéfice",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-033-profit.jpg",
      cost: 1
    }

  defp rake,
    do: %Card{
      name: "Rake, Maître Assassin",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-036-rake-master-assassin.jpg",
      cost: 7,
      champion: {:not_guard, 7}
    }

  defp rasmus,
    do: %Card{
      name: "Rasmus, le Contrebandier",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-037-rasmus-the-smuggler.jpg",
      cost: 4,
      champion: {:not_guard, 5}
    }

  defp smash_and_grab,
    do: %Card{
      name: "Casser et Piller",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-038-smash-and-grab.jpg",
      cost: 6
    }

  defp street_thug,
    do: %Card{
      name: "Bandit des Rues",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-039-street-thug.jpg",
      cost: 3,
      champion: {:not_guard, 4}
    }
end
