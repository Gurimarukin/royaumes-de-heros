defmodule Heros.Game.Lobby do
  def rename(game, name) do
    GenServer.call(game, {:update, {:rename, name}})
  end

  def handle_update({:rename, name}, _from, game) do
    {:reply, :ok, %{game | name: name}}
  end
end
