defmodule Heros.Game.Lobby do
  def rename(game, name) do
    GenServer.call(game, {:update, {:rename, name}})
  end

  def toggle_public(game) do
    GenServer.call(game, {:update, :toggle_public})
  end

  def start(game) do
    GenServer.call(game, {:update, :start})
  end

  def handle_update({:rename, name}, _from, game) do
    {:reply, :ok, %{game | name: name}}
  end

  def handle_update(:toggle_public, _from, game) do
    {:reply, :ok, %{game | is_public: not game.is_public}}
  end

  def handle_update(:start, _from, game) do
    {:reply, :ok, %{game | stage: :started}}
  end
end
