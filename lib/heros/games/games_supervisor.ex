defmodule Heros.GamesSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {DynamicSupervisor, name: Heros.GameSupervisor, strategy: :one_for_one},
      {Heros.Games, name: Heros.Games}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
