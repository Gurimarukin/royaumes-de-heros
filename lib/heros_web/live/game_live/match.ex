defmodule HerosWeb.GameLive.Match do
  def render(assigns) do
    players =
      sorted_players(assigns.game.match.players, assigns.session_id)
      |> Enum.map(fn {id, player} ->
        {id,
         update_in(player, [:deck], &length/1)
         |> update_in([:discard], &length/1)
         |> update_in([:hand], &length/1)}
      end)

    assigns = %{
      players: players,
      n_players: length(players),
      cards: []
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

  def default_assigns do
    []
  end
end
