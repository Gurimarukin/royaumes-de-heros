defmodule Heros.Cards.Imperial do
  alias Heros.Cards.Card

  def get do
    Card.with_id(:imperial, arkus()) ++
      Card.with_id(:imperial, close_ranks()) ++
      Card.with_id(:imperial, command()) ++
      Card.with_id(:imperial, darian()) ++
      Card.with_id(:imperial, domination()) ++
      Card.with_id(:imperial, cristov()) ++
      Card.with_id(:imperial, kraka()) ++
      Card.with_id(:imperial, man_at_arms(), 2) ++
      Card.with_id(:imperial, weyan()) ++
      Card.with_id(:imperial, rally_troops()) ++
      Card.with_id(:imperial, recruit(), 3) ++
      Card.with_id(:imperial, tithe_priest(), 2) ++
      Card.with_id(:imperial, taxation(), 3) ++
      Card.with_id(:imperial, word_of_power())
  end

  defp arkus,
    do: %Card{
      name: "Arkus, Dragon Impérial",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-001-arkus-imperial-dragon.jpg",
      cost: 8,
      champion: {:guard, 6}
    }

  defp close_ranks,
    do: %Card{
      name: "Serrez les Rangs",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-002-close-ranks.jpg",
      cost: 3
    }

  defp command,
    do: %Card{
      name: "Commandement",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-003-command.jpg",
      cost: 5
    }

  defp darian,
    do: %Card{
      name: "Darian, Mage de Guerre",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-004-darian-war-mage.jpg",
      cost: 4,
      champion: {:not_guard, 5}
    }

  defp domination,
    do: %Card{
      name: "Domination",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-005-domination.jpg",
      cost: 7
    }

  defp cristov,
    do: %Card{
      name: "Cristov, le Juste",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-006-cristov-the-just.jpg",
      cost: 5,
      champion: {:guard, 5}
    }

  defp kraka,
    do: %Card{
      name: "Kraka, Haut Prêtre",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-007-kraka-high-priest.jpg",
      cost: 6,
      champion: {:not_guard, 6}
    }

  defp man_at_arms,
    do: %Card{
      name: "Homme d'armes",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-008-man-at-arms.jpg",
      cost: 3,
      champion: {:guard, 4}
    }

  defp weyan,
    do: %Card{
      name: "Maître Weyan",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-010-master-weyan.jpg",
      cost: 4,
      champion: {:guard, 4}
    }

  defp rally_troops,
    do: %Card{
      name: "Ralliement",
      image:
        "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-011-rally-the-troops.jpg",
      cost: 4
    }

  defp recruit,
    do: %Card{
      name: "Recrutement",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-012-recruit.jpg",
      cost: 2
    }

  defp tithe_priest,
    do: %Card{
      name: "Percepteur de Dîme",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-015-tithe-priest.jpg",
      cost: 2,
      champion: {:not_guard, 3}
    }

  defp taxation,
    do: %Card{
      name: "Taxation",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-017-taxation.jpg",
      cost: 1
    }

  defp word_of_power,
    do: %Card{
      name: "Parole de Puissance",
      image: "https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-020-word-of-power.jpg",
      cost: 6
    }
end
