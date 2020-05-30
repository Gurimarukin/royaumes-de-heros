defmodule Heros.Game.Cards do
  alias Heros.Game.Cards.{Card, Guild, Imperial, Necros, Wild}

  @spec with_id(atom, integer) :: list({Card.id(), Card.t()})
  def with_id(key, n \\ 1) do
    List.duplicate(Card.get(key), n)
    |> Enum.map(&{UUID.uuid1(:hex), &1})
  end

  @spec gems :: list({Card.id(), Card.t()})
  def gems, do: with_id(:gem, 16)

  @spec market :: list({Card.id(), Card.t()})
  def market do
    Guild.get() ++
      Imperial.get() ++
      Necros.get() ++
      Wild.get()
  end
end
