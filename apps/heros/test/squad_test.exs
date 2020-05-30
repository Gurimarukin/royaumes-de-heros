defmodule Heros.SquadTest do
  use ExUnit.Case, async: true

  alias Heros.Squad
  alias Heros.Lobby

  defp user do
    {:ok, agent} = Agent.start_link(fn -> nil end)
    {agent, fn new_state -> Agent.update(agent, fn _ -> new_state end) end}
  end

  test "create squad" do
    {_p1, update_p1} = user()

    assert {:ok, pid} = Squad.start_link("p1", "Player 1", update_p1)

    assert squad = Squad.get(pid)

    assert squad == %Squad{
             members: [{"p1", [update_p1]}],
             state:
               {:lobby,
                %Lobby{
                  owner: "p1",
                  players: [{"p1", %Lobby.Player{name: "Player 1"}}]
                }}
           }
  end
end
