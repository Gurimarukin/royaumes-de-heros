defmodule Heros.Cards do
  alias Heros.Cards.{Card, Guild, Imperial, Necros, Wild}

  @spec gems :: list({Card.id(), Card.t()})
  def gems do
    Card.with_id(:gem, 16)
  end

  @spec market :: list({Card.id(), Card.t()})
  def market do
    Guild.get() ++
      Imperial.get() ++
      Necros.get() ++
      Wild.get()
  end
end
