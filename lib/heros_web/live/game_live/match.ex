defmodule HerosWeb.GameLive.Match do
  alias Heros.Cards.Card

  def render(assigns) do
    players =
      sorted_players(assigns.game.match.players, assigns.session_id)
      |> Enum.map(fn {id, player} ->
        player =
          update_in(player, [:deck], &length/1)
          |> update_in([:discard], &length/1)
          |> update_in([:hand], &length/1)

        name = Map.get(assigns.game.users, id)[:user_name]

        {id, player, name}
      end)

    assigns = %{
      players: players,
      n_players: length(players),
      cards: cards(assigns.game.match.players, assigns.session_id)
    }

    HerosWeb.GameView.render("match.html", assigns)
  end

  def sorted_players(players, session_id) do
    {current_player, others} = sorted_players(players, session_id, {nil, []})

    (current_player && [current_player | others]) ||
      others
  end

  defp sorted_players([], _session_id, acc), do: acc

  defp sorted_players([{session_id, current_player} | tail], session_id, {_current_player, acc}) do
    {{session_id, current_player}, tail ++ acc}
  end

  defp sorted_players([player | tail], session_id, {current_player, acc}) do
    sorted_players(tail, session_id, {current_player, acc ++ [player]})
  end

  defp cards(players, _session_id) do
    # {res, _} =
    #   Enum.reduce(players, {%{deck: []}, 0}, fn {_id, player}, {acc, i} ->
    #     acc =
    #       acc
    #       |> update_in(acc.deck, &(&1 ++ deck(player, i)))

    #     {acc, i + 1}
    #   end)

    {res, _} =
      Enum.flat_map_reduce(players, 0, fn {_id, player}, i ->
        {deck(player, i), i + 1}
      end)

    res
  end

  defp deck(player, i) do
    Enum.map(player.deck, fn {id, _card} ->
      {id, %{card: Card.hidden(), class: ~s(card card--deck-#{i})}}
    end)
  end

  def default_assigns do
    []
  end
end
