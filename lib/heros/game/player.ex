defmodule Heros.Game.Player do
  defstruct hp: 50,
            max_hp: 50,
            gold: 0,
            attack: 0,
            cards: %{
              deck: [],
              discard: [],
              hand: [],
              fight_zone: []
            }

  alias Heros.Cards
  alias Heros.Game.Player

  @behaviour Access

  @impl Access
  def fetch(player, key), do: Map.fetch(player, key)

  @impl Access
  def get_and_update(player, key, fun), do: Map.get_and_update(player, key, fun)

  @impl Access
  def pop(player, key, default \\ nil), do: Map.pop(player, key, default)

  def init do
    put_in(%Player{}.cards.deck, Cards.Decks.Base.shuffled())
  end

  def is_alive(player), do: player.hp > 0

  def is_exposed(_player) do
    true
  end

  def draw_cards(player, id_player, n, on_shuffle_discard \\ fn -> nil end)

  def draw_cards(player, _id_player, 0, _on_shuffle_discard), do: player

  def draw_cards(player, id_player, n, on_shuffle_discard) do
    if length(player.cards.deck) == 0 do
      if length(player.cards.discard) == 0 do
        player
      else
        player =
          put_in(player.cards.deck, Enum.shuffle(player.cards.discard))
          |> put_in([:cards, :discard], [])

        on_shuffle_discard.()

        player
      end
    else
      [head | tail] = player.cards.deck

      update_in(player.cards.hand, &(&1 ++ [head]))
      |> put_in([:cards, :deck], tail)
      |> draw_cards(id_player, n - 1)
    end
  end

  def sorted(players, player_id), do: sorted(players, player_id, {nil, []})

  defp sorted([], _player_id, acc), do: acc

  defp sorted([{player_id, current_player} | tail], player_id, {_current_player, acc}) do
    {{player_id, current_player}, tail ++ acc}
  end

  defp sorted([player | tail], player_id, {current_player, acc}) do
    sorted(tail, player_id, {current_player, acc ++ [player]})
  end

  def next(players, id_player) do
    case sorted(players, id_player) do
      {_, others} ->
        Enum.filter(others, fn {_id, player} -> Player.is_alive(player) end)
        |> List.first()
        |> elem(0)
    end
  end
end
