defmodule Heros.Player do
  defstruct is_admin: false,
            subscribed: MapSet.new()
end
