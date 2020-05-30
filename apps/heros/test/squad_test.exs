defmodule Heros.SquadTest do
  use ExUnit.Case, async: true

  alias Heros.{Game, Lobby, Squad}

  defp user do
    {:ok, agent} = Agent.start_link(fn -> nil end)

    %{
      get: fn -> Agent.get(agent, & &1) end,
      update: fn new_state -> Agent.update(agent, fn _ -> new_state end) end
    }
  end

  test "create squad" do
    p1 = user()
    p2 = user()
    p3 = user()

    assert {:ok, pid} = Squad.start_link("p1", "Player 1", p1.update)

    assert :sys.get_state(pid) == %Squad{
             members: [{"p1", [p1.update]}],
             state:
               {:lobby,
                %Lobby{
                  owner: "p1",
                  players: [{"p1", %Lobby.Player{name: "Player 1"}}],
                  ready: false
                }}
           }

    assert :error = GenServer.call(pid, :start_game)

    assert p1.get.() == nil

    # p2

    assert {:ok, state} = GenServer.call(pid, {:join, "p2", "Player 2", p2.update})

    lobby =
      {:lobby,
       %Lobby{
         owner: "p1",
         players: [
           {"p1", %Lobby.Player{name: "Player 1"}},
           {"p2", %Lobby.Player{name: "Player 2"}}
         ],
         ready: true
       }}

    assert state == lobby

    assert :sys.get_state(pid) == %Squad{
             members: [{"p1", [p1.update]}, {"p2", [p2.update]}],
             state: lobby
           }

    assert p1.get.() == lobby
    assert p2.get.() == lobby
    assert p3.get.() == nil

    # p3

    assert {:ok, state} = GenServer.call(pid, {:join, "p3", "Player 3", p3.update})

    lobby =
      {:lobby,
       %Lobby{
         owner: "p1",
         players: [
           {"p1", %Lobby.Player{name: "Player 1"}},
           {"p2", %Lobby.Player{name: "Player 2"}},
           {"p3", %Lobby.Player{name: "Player 3"}}
         ],
         ready: true
       }}

    assert state == lobby

    assert :sys.get_state(pid) == %Squad{
             members: [{"p1", [p1.update]}, {"p2", [p2.update]}, {"p3", [p3.update]}],
             state: lobby
           }

    assert p1.get.() == lobby
    assert p2.get.() == lobby
    assert p3.get.() == lobby

    assert {:ok, state} = GenServer.call(pid, {:leave, "p3"})

    lobby =
      {:lobby,
       %Lobby{
         owner: "p1",
         players: [
           {"p1", %Lobby.Player{name: "Player 1"}},
           {"p2", %Lobby.Player{name: "Player 2"}}
         ],
         ready: true
       }}

    assert state == lobby

    assert :sys.get_state(pid) == %Squad{
             members: [{"p1", [p1.update]}, {"p2", [p2.update]}],
             state: lobby
           }

    assert p1.get.() == lobby
    assert p2.get.() == lobby

    # start

    assert :error = GenServer.call(pid, {"p2", :start_game})

    assert {:ok, state} = GenServer.call(pid, {"p1", :start_game})

    assert {:game, game} = state
    assert game.__struct__ == Game
  end
end
