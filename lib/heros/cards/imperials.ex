defmodule Heros.Cards.Imperials do
  alias Heros.Cards.Card

  def get do
    Card.with_id(:arkus) ++
      Card.with_id(:close_ranks) ++
      Card.with_id(:command) ++
      Card.with_id(:darian) ++
      Card.with_id(:domination) ++
      Card.with_id(:cristov) ++
      Card.with_id(:kraka) ++
      Card.with_id(:man_at_arms, 2) ++
      Card.with_id(:weyan) ++
      Card.with_id(:rally_troops) ++
      Card.with_id(:recruit, 3) ++
      Card.with_id(:tithe_priest, 2) ++
      Card.with_id(:taxation, 3) ++
      Card.with_id(:word_of_power)
  end

  @spec fetch(:arkus) :: Heros.Cards.Card.t()
  def fetch(:arkus) do
    %Card{
      name: "Arkus, Dragon Impérial",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-001-arkus-imperial-dragon.jpg"
    }
  end

  def fetch(:close_ranks) do
    %Card{
      name: "Serrez les Rangs",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-002-close-ranks.jpg"
    }
  end

  def fetch(:command) do
    %Card{
      name: "Commandement",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-003-command.jpg"
    }
  end

  def fetch(:darian) do
    %Card{
      name: "Darian, Mage de Guerre",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-004-darian-war-mage.jpg"
    }
  end

  def fetch(:domination) do
    %Card{
      name: "Domination",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-005-domination.jpg"
    }
  end

  def fetch(:cristov) do
    %Card{
      name: "Cristov, le Juste",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-006-cristov-the-just.jpg"
    }
  end

  def fetch(:kraka) do
    %Card{
      name: "Kraka, Haut Prêtre",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-007-kraka-high-priest.jpg"
    }
  end

  def fetch(:man_at_arms) do
    %Card{
      name: "Kraka, Haut Prêtre",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-008-man-at-arms.jpg"
    }
  end

  def fetch(:weyan) do
    %Card{
      name: "Maître Weyan",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-010-master-weyan.jpg"
    }
  end

  def fetch(:rally_troops) do
    %Card{
      name: "Ralliement",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-011-rally-the-troops.jpg"
    }
  end

  def fetch(:recruit) do
    %Card{
      name: "Recrutement",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-012-recruit.jpg"
    }
  end

  def fetch(:tithe_priest) do
    %Card{
      name: "Percepteur de Dîme",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-015-tithe-priest.jpg"
    }
  end

  def fetch(:taxation) do
    %Card{
      name: "Taxation",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-017-taxation.jpg"
    }
  end

  def fetch(:word_of_power) do
    %Card{
      name: "Parole de Puissance",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-020-word-of-power.jpg"
    }
  end

  # def primary_effect(game, :shortsword), do: Card.add_attack(game, 2)
end
