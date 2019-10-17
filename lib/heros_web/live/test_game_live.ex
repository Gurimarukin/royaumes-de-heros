defmodule HerosWeb.TestGameLive do
  use Phoenix.LiveView

  def mount(_session, socket) do
    {:ok, socket}
  end

  def render(_assigns) do
    players = [
      {"player1",
       %{
         index: 0,
         name: "Bob",
         is_current: true,
         hp: 50,
         max_hp: 50,
         gold: 0,
         attack: 0,
         deck: [{"card-0-0", :gold}],
         discard: [{"card-0-10", :dagger}],
         hand: [
           {"card-0-21", :lys},
           {"card-0-22", :lys},
           {"card-0-23", :lys},
           {"card-0-24", :lys},
           {"card-0-25", :lys},
           {"card-0-26", :lys},
           {"card-0-27", :lys},
           {"card-0-28", :lys}
         ],
         fight_zone: [
           {"card-0-30", :gold},
           {"card-0-31", :gold},
           {"card-0-32", :gold},
           {"card-0-33", :gold},
           {"card-0-34", :gold},
           {"card-0-35", :gold},
           {"card-0-36", :gold},
           {"card-0-37", :gold},
           {"card-0-38", :gold},
           {"card-0-39", :gold},
           {"card-0-40", :gold},
           {"card-0-41", :gold},
           {"card-0-42", :gold},
           {"card-0-43", :gold},
           {"card-0-44", :gold},
           {"card-0-45", :gold}
         ]
       }},
      {"player2",
       %{
         index: 1,
         name: "John",
         is_current: false,
         hp: 50,
         max_hp: 50,
         gold: 0,
         attack: 0,
         deck: [{"card-1-0", :gold}],
         discard: [{"card-1-10", :dagger}],
         hand: [
           {"card-1-21", :lys},
           {"card-1-22", :lys},
           {"card-1-23", :lys},
           {"card-1-24", :lys},
           {"card-1-25", :lys},
           {"card-1-26", :lys},
           {"card-1-27", :lys},
           {"card-1-28", :lys}
         ],
         fight_zone: [
           {"card-1-30", :arkus},
           {"card-1-31", :arkus},
           {"card-1-32", :arkus},
           {"card-1-33", :arkus},
           {"card-1-34", :arkus},
           {"card-1-35", :arkus},
           {"card-1-36", :arkus},
           {"card-1-37", :arkus},
           {"card-1-38", :arkus},
           {"card-1-39", :arkus},
           {"card-1-40", :arkus},
           {"card-1-41", :arkus},
           {"card-1-42", :arkus},
           {"card-1-43", :arkus},
           {"card-1-44", :arkus},
           {"card-1-45", :arkus}
         ]
       }}
    ]

    match = %{
      gems: [
        {"card-0", :gem}
      ],
      market: [
        {"card-1", :varrick},
        {"card-2", :varrick},
        {"card-3", :varrick},
        nil,
        {"card-4", :varrick}
      ]
    }

    cards =
      Enum.flat_map(players, fn {_id, player} ->
        Enum.map(player.deck, fn {id, _} -> {id, nil} end) ++
          Enum.map(player.discard, fn {id, _} -> {id, nil} end) ++
          Enum.map(player.hand, fn {id, _} -> {id, nil} end) ++
          Enum.map(player.fight_zone, fn {id, _} -> {id, nil} end) ++
          Enum.map(match.gems, fn {id, _} -> {id, nil} end) ++
          Enum.flat_map(match.market, fn card ->
            case card do
              {id, _} -> [{id, nil}]
              _ -> []
            end
          end)
      end)

    assigns = %{
      players: players,
      n_players: length(players),
      cards:
        Enum.with_index(players)
        |> Enum.reduce(cards, fn {{id, player}, i}, cards ->
          HerosWeb.GameLive.Match.deck(cards, player, i)
          |> HerosWeb.GameLive.Match.discard(player, i)
          |> HerosWeb.GameLive.Match.hand(player, id == "player1", i)
          |> HerosWeb.GameLive.Match.fight_zone(player, i)
        end)
        |> HerosWeb.GameLive.Match.gems(match)
        |> HerosWeb.GameLive.Match.market(match)
        |> Enum.map(fn {id, card} ->
          case card do
            nil -> nil
            card -> %{id: id, image: card.card.image, class: card.class}
          end
        end)
    }

    HerosWeb.GameView.render("match.html", assigns)
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end
end
