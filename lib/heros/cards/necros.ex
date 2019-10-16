defmodule Heros.Cards.Necros do
  alias Heros.Cards.Card

  def get do
    Card.with_id(:cult_priest, 2) ++
      Card.with_id(:dark_energy) ++
      Card.with_id(:dark_reward) ++
      Card.with_id(:death_cultist, 2) ++
      Card.with_id(:death_touch, 3) ++
      Card.with_id(:rayla) ++
      Card.with_id(:influence, 3) ++
      Card.with_id(:krythos) ++
      Card.with_id(:life_drain) ++
      Card.with_id(:lys) ++
      Card.with_id(:the_rot, 2) ++
      Card.with_id(:tyrannor) ++
      Card.with_id(:varrick)
  end

  def fetch(card) do
    case fetch_bis(card) do
      nil -> nil
      card -> put_in(card.faction, :necros)
    end
  end

  defp fetch_bis(:cult_priest) do
    %Card{
      name: "Prêtre du Culte",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-041-cult-priest.jpg",
      cost: 3,
      champion: {:not_guard, 4}
    }
  end

  defp fetch_bis(:dark_energy) do
    %Card{
      name: "Énergie Sombre",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-043-dark-energy.jpg",
      cost: 4
    }
  end

  defp fetch_bis(:dark_reward) do
    %Card{
      name: "Sombre Récompense",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-044-dark-reward.jpg",
      cost: 5
    }
  end

  defp fetch_bis(:death_cultist) do
    %Card{
      name: "Cultiste de la Mort",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-045-death-cultist.jpg",
      cost: 2,
      champion: {:guard, 3}
    }
  end

  defp fetch_bis(:death_touch) do
    %Card{
      name: "Contact Mortel",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-047-death-touch.jpg",
      cost: 1
    }
  end

  defp fetch_bis(:rayla) do
    %Card{
      name: "Rayla, Tisseuse de Fins",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-050-rayla-endweaver.jpg",
      cost: 4,
      champion: {:not_guard, 4}
    }
  end

  defp fetch_bis(:influence) do
    %Card{
      name: "Influence",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-051-influence.jpg",
      cost: 2
    }
  end

  defp fetch_bis(:krythos) do
    %Card{
      name: "Krythos, Maître Vampire",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-054-krythos-master-vampire.jpg",
      cost: 7,
      champion: {:not_guard, 6}
    }
  end

  defp fetch_bis(:life_drain) do
    %Card{
      name: "Drain de Vie",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-055-life-drain.jpg",
      cost: 6
    }
  end

  defp fetch_bis(:lys) do
    %Card{
      name: "Lys, l'Invisible",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-056-lys-the-unseen.jpg",
      cost: 6,
      champion: {:guard, 5}
    }
  end

  defp fetch_bis(:the_rot) do
    %Card{
      name: "Putréfaction",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-057-the-rot.jpg",
      cost: 3
    }
  end

  defp fetch_bis(:tyrannor) do
    %Card{
      name: "Tyrannor, le Dévoreur",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-059-tyrannor-the-devourer.jpg",
      cost: 8,
      champion: {:guard, 6}
    }
  end

  defp fetch_bis(:varrick) do
    %Card{
      name: "Varrick, le Nécromancien",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-060-varrick-the-necromancer.jpg",
      cost: 5,
      champion: {:not_guard, 3}
    }
  end

  defp fetch_bis(_), do: nil

  # def primary_effect(game, :shortsword), do: Card.add_attack(game, 2)
end
