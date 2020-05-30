defmodule Heros.SquadTest do
  use ExUnit.Case, async: true

  alias Heros.Squad

  defp user do
    {:ok, agent} = Agent.start_link(fn -> nil end)
    {agent, fn new_state -> Agent.update(agent, fn _ -> new_state end) end}
  end

  test "create squad" do
    {_u1, update_u1} = user()

    assert squad = Squad.create("u1", update_u1)

    assert squad == %Squad{
             users: [{"u1", [update_u1]}]
           }
  end
end
