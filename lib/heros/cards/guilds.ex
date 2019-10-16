defmodule Heros.Cards.Guilds do
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

  def fetch(:borg) do
    %Card{
      name: "Borg, Mercenaire Ogre",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-021-borg-ogre-mercenary.jpg"
    }
  end

  def fetch(:bribe) do
    %Card{
      name: "Pot-de-vin",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-022-bribe.jpg"
    }
  end

  def fetch(:death_threat) do
    %Card{
      name: "Menace de Mort",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-025-death-threat.jpg"
    }
  end

  def fetch(:deception) do
    %Card{
      name: "Duperie",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-026-deception.jpg"
    }
  end

  def fetch(:fire_bomb) do
    %Card{
      name: "Bombe Incendiaire",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-027-fire-bomb.jpg"
    }
  end

  def fetch(:hit_job) do
    %Card{
      name: "Assassinat",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-028-hit-job.jpg"
    }
  end

  def fetch(:intimidation) do
    %Card{
      name: "Intimidation",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-029-intimidation.jpg"
    }
  end

  def fetch(:myros) do
    %Card{
      name: "Myros, Mage de la Guilde",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-031-myros-guild-mage.jpg"
    }
  end

  def fetch(:parov) do
    %Card{
      name: "Parov, l'Executeur",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-032-parov-the-enforcer.jpg"
    }
  end

  def fetch(:profit) do
    %Card{
      name: "Bénéfice",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-033-profit.jpg"
    }
  end

  def fetch(:rake) do
    %Card{
      name: "Rake, Maître Assassin",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-036-rake-master-assassin.jpg"
    }
  end

  def fetch(:rasmus) do
    %Card{
      name: "Rasmus, le Contrebandier",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-037-rasmus-the-smuggler.jpg"
    }
  end

  def fetch(:smash_and_grab) do
    %Card{
      name: "Casser et Piller",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-038-smash-and-grab.jpg"
    }
  end

  def fetch(:street_thug) do
    %Card{
      name: "Bandit des Rues",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-039-street-thug.jpg"
    }
  end

  # def primary_effect(game, :shortsword), do: Card.add_attack(game, 2)
end
