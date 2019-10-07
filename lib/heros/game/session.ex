defmodule Heros.Game.Session do
  defstruct connected_views: MapSet.new(),
            user_name: nil
end
