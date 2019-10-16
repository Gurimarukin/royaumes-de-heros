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

  def fetch(:cult_priest) do
    %Card{
      name: "Prêtre du Culte",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-041-cult-priest.jpg"
    }
  end

  def fetch(:dark_energy) do
    %Card{
      name: "Énergie Sombre",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-043-dark-energy.jpg"
    }
  end

  def fetch(:dark_reward) do
    %Card{
      name: "Sombre Récompense",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-044-dark-reward.jpg"
    }
  end

  def fetch(:death_cultist) do
    %Card{
      name: "Cultiste de la Mort",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-045-death-cultist.jpg"
    }
  end

  def fetch(:death_touch) do
    %Card{
      name: "Contact Mortel",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-047-death-touch.jpg"
    }
  end

  def fetch(:rayla) do
    %Card{
      name: "Rayla, Tisseuse de Fins",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-050-rayla-endweaver.jpg"
    }
  end

  def fetch(:influence) do
    %Card{
      name: "Influence",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-051-influence.jpg"
    }
  end

  def fetch(:krythos) do
    %Card{
      name: "Krythos, Maître Vampire",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-054-krythos-master-vampire.jpg"
    }
  end

  def fetch(:life_drain) do
    %Card{
      name: "Drain de Vie",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-055-life-drain.jpg"
    }
  end

  def fetch(:lys) do
    %Card{
      name: "Lys, l'Invisible",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-056-lys-the-unseen.jpg"
    }
  end

  def fetch(:the_rot) do
    %Card{
      name: "Putréfaction",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-057-the-rot.jpg"
    }
  end

  def fetch(:tyrannor) do
    %Card{
      name: "Tyrannor, le Dévoreur",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-059-tyrannor-the-devourer.jpg"
    }
  end

  def fetch(:varrick) do
    %Card{
      name: "Varrick, le Nécromancien",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-060-varrick-the-necromancer.jpg"
    }
  end

  # def primary_effect(game, :shortsword), do: Card.add_attack(game, 2)
end
