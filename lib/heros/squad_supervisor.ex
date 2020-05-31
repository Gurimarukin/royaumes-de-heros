defmodule Heros.SquadsSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {DynamicSupervisor, name: Heros.SquadSupervisor, strategy: :one_for_one},
      {Heros.Squads, name: Heros.Squads}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
