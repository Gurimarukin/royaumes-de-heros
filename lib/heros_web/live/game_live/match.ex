defmodule HerosWeb.GameLive.Match do
  import Phoenix.LiveView, only: [assign: 2]

  alias Heros.Cards.Card
  alias Heros.{Game, Utils}
  alias HerosWeb.GameLive.Stage

  @behaviour Stage

  @impl Stage
  def default_assigns(game), do: [cards: maybe_cards(game)]

  def maybe_cards({:ok, game}), do: if(game.stage == :started, do: default_cards(game), else: [])

  def maybe_cards(_), do: []

  defp default_cards(game) do
    Enum.flat_map(game.match.players, fn {_id, player} ->
      nil_cards(player.cards.deck) ++
        nil_cards(player.cards.discard) ++
        nil_cards(player.cards.hand) ++
        nil_cards(player.cards.fight_zone)
    end) ++
      nil_cards(game.match.gems) ++
      nil_cards(game.match.market) ++
      nil_cards(game.match.market_deck) ++
      nil_cards(game.match.sacrifice)
  end

  defp nil_cards(cards), do: Enum.map(cards, fn {id, _} -> {id, nil} end)

  @impl Stage
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
           discard: player.cards.discard,
           hand: player.cards.hand,
           deck: player.cards.deck,
           fight_zone: player.cards.fight_zone
         }}
      end)
      |> sorted_players(assigns.session.id)

    assigns = %{
      players: players,
      n_players: length(players),
      cards:
        cards(assigns.cards, players, assigns.session.id)
        |> Enum.map(fn {id, card} -> [id, update_in(card.card, &Map.from_struct/1)] end)
    }

    HerosWeb.GameView.render("match.html", assigns)
  end

  defp sorted_players(players, session_id) do
    {current_player, others} = Game.Match.sorted_players(players, session_id)

    (current_player && [current_player | others]) ||
      others
  end

  def player_classes(player) do
    classes =
      [
        "player",
        ~s"player--p#{player.index}"
      ] ++
        if player.is_current, do: ["player--current"], else: []

    Enum.join(classes, " ")
  end

  defp cards(cards, players, session_id) do
    Enum.with_index(players)
    |> Enum.reduce(cards, fn {{id, player}, i}, cards ->
      deck(cards, player, i)
      |> hand(player, id == session_id, i)
      |> fight_zone(player, i)
      |> discard(player, i)
    end)
  end

  defp deck(cards, player, i) do
    Enum.reduce(player.deck, cards, fn {id, _card}, cards ->
      Utils.keyreplace(cards, id, %{card: Card.hidden(), class: ~s(card card--deck-#{i})})
    end)
  end

  defp hand(cards, player, visible, i) do
    hand = Enum.with_index(player.hand)

    if visible do
      Enum.reduce(hand, cards, fn {{id, card}, j}, cards ->
        Utils.keyreplace(cards, id, %{
          card: Card.fetch(card),
          class: ~s(card card--hand card--hand-p#{i} card--hand-#{j})
        })
      end)
    else
      Enum.reduce(hand, cards, fn {{id, _card}, j}, cards ->
        Utils.keyreplace(cards, id, %{
          card: Card.hidden(),
          class: ~s(card card--hand card--hand-p#{i} card--hand-#{j})
        })
      end)
    end
  end

  defp fight_zone(cards, player, i) do
    Enum.with_index(player.fight_zone)
    |> Enum.reduce(cards, fn {{id, card}, j}, cards ->
      Utils.keyreplace(cards, id, %{
        card: Card.fetch(card),
        class: ~s(card card--fight-zone card--fight-zone-p#{i} card--fight-zone-#{j})
      })
    end)
  end

  defp discard(cards, player, i) do
    Enum.reduce(player.discard, cards, fn {id, card}, cards ->
      Utils.keyreplace(cards, id, %{card: Card.fetch(card), class: ~s(card card--discard-#{i})})
    end)
  end

  @impl Stage
  def handle_event("card-click", %{"button" => "right", "id" => _id}, socket) do
    {:noreply, socket}
  end

  def handle_event("card-click", %{"button" => "left", "id" => id_card}, socket) do
    Heros.Game.Match.play_card(socket.assigns.game_pid, socket.assigns.session.id, id_card)
    {:noreply, socket}
  end

  def handle_event("end-turn", _params, socket) do
    Heros.Game.Match.end_turn(socket.assigns.game_pid, socket.assigns.session.id)
    {:noreply, socket}
  end

  @impl Stage
  def handle_info(_msg, _socket), do: raise(MatchError, message: "no match of handle_info/2")

  def on_start(socket, game), do: assign(socket, cards: default_cards(game))
end
