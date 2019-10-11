defmodule HerosWeb.GameLive.Match do
  alias Heros.Cards.Card

  def render(assigns) do
    players = sorted_players(assigns.game.match.players, assigns.session.id)

    simple_players =
      Enum.map(players, fn {id, player} ->
        player =
          update_in(player, [:deck], &length/1)
          |> update_in([:discard], &length/1)
          |> update_in([:hand], &length/1)

        name = Map.get(assigns.game.users, id)[:user_name]

        {id, player, name}
      end)

    assigns = %{
      players: simple_players,
      n_players: length(players),
      cards: cards(players, assigns.session.id)
    }

    HerosWeb.GameView.render("match.html", assigns)
  end

  defp sorted_players(players, session_id) do
    {current_player, others} = Heros.Game.Match.sorted_players(players, session_id)

    (current_player && [current_player | others]) ||
      others
  end

  defp cards(players, session_id) do
    Enum.with_index(players)
    |> Enum.flat_map(fn {{id, player}, i} ->
      deck(player, i) ++
        hand(player, id == session_id, i)
    end)
  end

  defp deck(player, i) do
    Enum.map(player.deck, fn {id, _card} ->
      {id, %{card: Card.hidden(), class: ~s(card card--deck-#{i})}}
    end)
  end

  defp hand(player, visible, i) do
    hand = Enum.with_index(player.hand)

    if visible do
      Enum.map(hand, fn {{id, card}, j} ->
        {id,
         %{card: Card.fetch(card), class: ~s(card card--hand card--hand-p#{i} card--hand-#{j})}}
      end)
    else
      Enum.map(hand, fn {{id, _card}, j} ->
        {id, %{card: Card.hidden(), class: ~s(card card--hand card--hand-p#{i} card--hand-#{j})}}
      end)
    end
  end

  def default_assigns do
    []
  end
end
