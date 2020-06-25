defmodule Heros.Squads do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def list(squads) do
    GenServer.call(squads, :list)
    |> Enum.map(fn {id, squad} ->
      Task.async(fn -> Map.put(Heros.Squad.short(squad), :id, id) end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def lookup(squads, id) do
    GenServer.call(squads, {:lookup, id})
  end

  def create(squads, id, broadcast_update) do
    :ok = GenServer.call(squads, {:create, id, broadcast_update})
  end

  def init(:ok) do
    ids = %{}
    refs = %{}
    {:ok, {ids, refs}}
  end

  def handle_call(:list, _from, {ids, refs}) do
    {:reply, ids, {ids, refs}}
  end

  def handle_call({:lookup, id}, _from, {ids, refs}) do
    {:reply, Map.fetch(ids, id), {ids, refs}}
  end

  def handle_call({:create, id, broadcast_update}, _from, {ids, refs}) do
    if Map.has_key?(ids, id) do
      {:reply, {:error, :already_exists}, {ids, refs}}
    else
      {:ok, squad} =
        DynamicSupervisor.start_child(
          Heros.SquadSupervisor,
          {Heros.Squad, [broadcast_update: broadcast_update]}
        )

      ref = Process.monitor(squad)

      ids = Map.put(ids, id, squad)
      refs = Map.put(refs, ref, id)

      {:reply, :ok, {ids, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {ids, refs}) do
    {id, refs} = Map.pop(refs, ref)
    ids = Map.delete(ids, id)
    {:noreply, {ids, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
