defmodule Heros.Game.Player do
  defstruct id: nil,
            hp: 50,
            deck: [],
            discard: [],
            hand: [],
            gold: 0,
            attack: 0
end
