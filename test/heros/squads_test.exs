defmodule Heros.SquadsTest do
  use ExUnit.Case, async: true

  alias Heros.Squads

  defp user do
    {:ok, agent} = Agent.start_link(fn -> nil end)

    %{
      get: fn -> Agent.get(agent, & &1) end,
      update: fn new_state -> Agent.update(agent, fn _ -> new_state end) end
    }
  end

  setup do
    squads = start_supervised!(Squads)
    %{squads: squads}
  end

  test "spawns squads", %{squads: squads} do
    p1 = user()

    assert Squads.lookup(squads, "squad") == :error

    squad_id = Squads.create(squads, {"p1", "Player 1", p1.update})

    assert {:ok, squad_pid} = Squads.lookup(squads, squad_id)

    assert is_pid(squad_pid)

    assert Squads.list(squads) == [
             %{
               id: squad_id,
               stage: :lobby,
               n_players: 1
             }
           ]
  end

  test "removes squads on exit", %{squads: squads} do
    p1 = user()

    squad_id = Squads.create(squads, {"p1", "Player 1", p1.update})

    {:ok, squad} = Squads.lookup(squads, squad_id)

    Agent.stop(squad)

    assert Squads.lookup(squads, squad_id) == :error
  end
end
