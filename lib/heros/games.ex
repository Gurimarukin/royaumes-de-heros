defmodule Heros.Games do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def list(games) do
    GenServer.call(games, :list)
    |> Enum.map(fn {id, game} ->
      Map.put(Heros.Game.short(game), :id, id)
    end)
  end

  def list_joinable(games) do
    list(games)
    |> Enum.filter(fn game ->
      game.is_public and game.stage == :lobby
    end)
  end

  @doc """
  Looks up the bucket pid for `id` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(games, id) do
    GenServer.call(games, {:lookup, id})
  end

  @doc """
  Creates a new `Game` in the server with a unique `id`.

  Returns the id.
  """
  def create(games) do
    id = UUID.uuid1(:hex)
    :ok = GenServer.call(games, {:create, id})
    id
  end

  def delete(games, id) do
    GenServer.call(games, {:delete, id})
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

  def handle_call({:create, id}, _from, {ids, refs}) do
    if Map.has_key?(ids, id) do
      {:reply, {:error, :already_exists}, {ids, refs}}
    else
      {:ok, game} = DynamicSupervisor.start_child(Heros.GameSupervisor, Heros.Game)
      ref = Process.monitor(game)

      ids = Map.put(ids, id, game)
      refs = Map.put(refs, ref, id)

      {:reply, :ok, {ids, refs}}
    end
  end

  def handle_call({:delete, id}, _from, {ids, refs}) do
    if Map.has_key?(ids, id) do
      {:ok, game} = Map.fetch(ids, id)
      GenServer.stop(game)

      {:reply, :ok, {ids, refs}}
    else
      {:reply, {:error, :not_found}, {ids, refs}}
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
