defmodule Heros.Cards.Necros do
  alias Heros.Cards.Card

  def get do
    Card.with_id(:necros, cult_priest(), 2) ++
      Card.with_id(:necros, dark_energy()) ++
      Card.with_id(:necros, dark_reward()) ++
      Card.with_id(:necros, death_cultist(), 2) ++
      Card.with_id(:necros, death_touch(), 3) ++
      Card.with_id(:necros, rayla()) ++
      Card.with_id(:necros, influence(), 3) ++
      Card.with_id(:necros, krythos()) ++
      Card.with_id(:necros, life_drain()) ++
      Card.with_id(:necros, lys()) ++
      Card.with_id(:necros, the_rot(), 2) ++
      Card.with_id(:necros, tyrannor()) ++
      Card.with_id(:necros, varrick())
  end

  defp cult_priest,
    do: %Card{
      name: "Prêtre du Culte",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-041-cult-priest.jpg",
      cost: 3,
      champion: {:not_guard, 4}
    }

  defp dark_energy,
    do: %Card{
      name: "Énergie Sombre",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-043-dark-energy.jpg",
      cost: 4
    }

  defp dark_reward,
    do: %Card{
      name: "Sombre Récompense",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-044-dark-reward.jpg",
      cost: 5
    }

  defp death_cultist,
    do: %Card{
      name: "Cultiste de la Mort",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-045-death-cultist.jpg",
      cost: 2,
      champion: {:guard, 3}
    }

  defp death_touch,
    do: %Card{
      name: "Contact Mortel",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-047-death-touch.jpg",
      cost: 1
    }

  defp rayla,
    do: %Card{
      name: "Rayla, Tisseuse de Fins",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-050-rayla-endweaver.jpg",
      cost: 4,
      champion: {:not_guard, 4}
    }

  defp influence,
    do: %Card{
      name: "Influence",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-051-influence.jpg",
      cost: 2
    }

  defp krythos,
    do: %Card{
      name: "Krythos, Maître Vampire",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-054-krythos-master-vampire.jpg",
      cost: 7,
      champion: {:not_guard, 6}
    }

  defp life_drain,
    do: %Card{
      name: "Drain de Vie",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-055-life-drain.jpg",
      cost: 6
    }

  defp lys,
    do: %Card{
      name: "Lys, l'Invisible",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-056-lys-the-unseen.jpg",
      cost: 6,
      champion: {:guard, 5}
    }

  defp the_rot,
    do: %Card{
      name: "Putréfaction",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-057-the-rot.jpg",
      cost: 3
    }

  defp tyrannor,
    do: %Card{
      name: "Tyrannor, le Dévoreur",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-059-tyrannor-the-devourer.jpg",
      cost: 8,
      champion: {:guard, 6}
    }

  defp varrick,
    do: %Card{
      name: "Varrick, le Nécromancien",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-060-varrick-the-necromancer.jpg",
      cost: 5,
      champion: {:not_guard, 3}
    }
end
