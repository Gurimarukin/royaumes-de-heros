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

  @behaviour Access

  @impl Access
  def fetch(player, key), do: Map.fetch(player, key)

  @impl Access
  def get_and_update(player, key, fun), do: Map.get_and_update(player, key, fun)

  @impl Access
  def pop(player, key, default \\ nil), do: Map.pop(player, key, default)
end
