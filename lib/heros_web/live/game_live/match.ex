defmodule HerosWeb.GameLive.Match do
  alias Heros.Cards.Card
  alias Heros.Game

  def render(assigns) do
    players =
      Enum.with_index(assigns.game.match.players)
      |> Enum.map(fn {{id, player}, i} ->
        {id,
         %{
           index: i,
           name: Map.get(assigns.game.users, id)[:user_name],
           is_current: Game.Match.is_current_player(assigns.game.match, id),
           hp: player.hp,
           max_hp: player.max_hp,
           gold: player.gold,
           attack: player.attack,
           discard: player.discard,
           hand: player.hand,
           deck: player.deck
         }}
      end)
      |> sorted_players(assigns.session.id)

    assigns = %{
      players: players,
      n_players: length(players),
      cards: cards(players, assigns.session.id)
    }

    HerosWeb.GameView.render("match.html", assigns)
  end

  defp sorted_players(players, session_id) do
    {current_player, others} = Game.Match.sorted_players(players, session_id)

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
