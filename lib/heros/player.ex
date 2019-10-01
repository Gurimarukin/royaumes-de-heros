defmodule Heros.Player do
  defstruct is_owner: false,
            subscribed: MapSet.new()
end
