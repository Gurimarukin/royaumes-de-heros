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

  defp champions(cards) do
    Enum.map(cards, fn {_id, card} -> Card.fetch(card) end)
    |> Enum.filter(&Card.is_champion/1)
  end
end
