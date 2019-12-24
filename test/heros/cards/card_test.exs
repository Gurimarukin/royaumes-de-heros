defmodule Heros.Cards.CardTest do
  use ExUnit.Case

  alias Heros.Cards.{Card, Guild, Imperial, Necros, Wild}

  test "toto" do
    assert length(Guild.get()) == 20
    assert length(Imperial.get()) == 20
    assert length(Necros.get()) == 20
    assert length(Wild.get()) == 20

    assert length(champions(Guild.get())) == 7
    assert length(champions(Imperial.get())) == 9
    assert length(champions(Necros.get())) == 9
    assert length(champions(Wild.get())) == 9
  end

  defp champions(cards), do: Enum.filter(cards, fn {_, card} -> Card.is_champion(card) end)
end