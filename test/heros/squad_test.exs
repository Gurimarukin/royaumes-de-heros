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

    assert {:ok, pid} = Squad.start_link([])

    assert Squad.get(pid) == %Squad{
             owner: nil,
             members: [],
             state: {:lobby, %Lobby{players: [], ready: false}}
           }

    assert :error = GenServer.call(pid, :start_game)

    assert p1.get.() == nil

    # p1 joins

    assert {:ok, _} = GenServer.call(pid, {:join, "p1", "Player 1", p1.update})

    lobby = %Lobby{players: [{"p1", %Lobby.Player{name: "Player 1"}}], ready: false}

    assert p1.get.() == {:lobby, lobby}
    assert p2.get.() == nil
    assert p3.get.() == nil

    assert Squad.get(pid) == %Squad{
             owner: "p1",
             members: [{"p1", [p1.update]}],
             state: {:lobby, lobby}
           }

    # p2 joins

    assert {:ok, _} = GenServer.call(pid, {:join, "p2", "Player 2", p2.update})

    lobby = %Lobby{
      players: [
        {"p1", %Lobby.Player{name: "Player 1"}},
        {"p2", %Lobby.Player{name: "Player 2"}}
      ],
      ready: true
    }

    assert p1.get.() == {:lobby, lobby}
    assert p2.get.() == {:lobby, lobby}
    assert p3.get.() == nil

    assert Squad.get(pid) == %Squad{
             owner: "p1",
             members: [{"p1", [p1.update]}, {"p2", [p2.update]}],
             state: {:lobby, lobby}
           }

    # p3 joins

    assert {:ok, _} = GenServer.call(pid, {:join, "p3", "Player 3", p3.update})

    lobby = %Lobby{
      players: [
        {"p1", %Lobby.Player{name: "Player 1"}},
        {"p2", %Lobby.Player{name: "Player 2"}},
        {"p3", %Lobby.Player{name: "Player 3"}}
      ],
      ready: true
    }

    assert p1.get.() == {:lobby, lobby}
    assert p2.get.() == {:lobby, lobby}
    assert p3.get.() == {:lobby, lobby}

    assert Squad.get(pid) == %Squad{
             owner: "p1",
             members: [{"p1", [p1.update]}, {"p2", [p2.update]}, {"p3", [p3.update]}],
             state: {:lobby, lobby}
           }

    # p1 leaves

    assert {:ok, _} = GenServer.call(pid, {:leave, "p1"})

    prev_lobby = lobby

    lobby = %Lobby{
      players: [
        {"p2", %Lobby.Player{name: "Player 2"}},
        {"p3", %Lobby.Player{name: "Player 3"}}
      ],
      ready: true
    }

    assert p1.get.() == {:lobby, prev_lobby}
    assert p2.get.() == {:lobby, lobby}
    assert p3.get.() == {:lobby, lobby}

    assert Squad.get(pid) == %Squad{
             owner: "p2",
             members: [{"p2", [p2.update]}, {"p3", [p3.update]}],
             state: {:lobby, lobby}
           }

    # start

    assert :error = GenServer.call(pid, {"p3", :start_game})

    assert {:ok, _} = GenServer.call(pid, {"p2", :start_game})

    %{state: {:game, game}} = Squad.get(pid)

    assert p1.get.() == {:lobby, prev_lobby}
    assert p2.get.() == {:game, game}
    assert p3.get.() == {:game, game}

    assert game.__struct__ == Game
  end
end
