defmodule Heros.SquadsTest do
  use ExUnit.Case, async: true

  alias Heros.Squads

  setup do
    squads = start_supervised!(Squads)
    %{squads: squads}
  end

  test "spawns squads", %{squads: squads} do
    assert Squads.lookup(squads, "squad") == :error

    squad_id = Squads.create(squads)

    assert {:ok, squad_pid} = Squads.lookup(squads, squad_id)

    assert is_pid(squad_pid)

    assert Squads.list(squads) == [
             %{
               id: squad_id,
               stage: :lobby,
               n_players: 0
             }
           ]
  end

  test "removes squads on exit", %{squads: squads} do
    squad_id = Squads.create(squads)

    {:ok, squad} = Squads.lookup(squads, squad_id)

    Agent.stop(squad)

    assert Squads.lookup(squads, squad_id) == :error
  end
end
