defmodule Heros.SquadsTest do
  use ExUnit.Case, async: true

  alias Heros.Squads

  setup do
    squads = start_supervised!(Squads)
    %{squads: squads}
  end

  test "spawns squads", %{squads: squads} do
    assert Squads.lookup(squads, "squad") == :error

    :ok = Squads.create(squads, :squad_id, fn _ -> nil end)

    assert {:ok, squad_pid} = Squads.lookup(squads, :squad_id)

    assert is_pid(squad_pid)

    assert Squads.list(squads) == [
             %{
               id: :squad_id,
               stage: :lobby,
               n_players: 0
             }
           ]
  end

  test "removes squads on exit", %{squads: squads} do
    :ok = Squads.create(squads, :squad_id, fn _ -> nil end)

    {:ok, squad_pid} = Squads.lookup(squads, :squad_id)

    Agent.stop(squad_pid)

    assert Squads.lookup(squads, :squad_id) == :error
  end
end
