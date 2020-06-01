defmodule Heros.SquadTest do
  use ExUnit.Case, async: true

  alias Heros.{Game, Lobby, Squad}

  test "create squad" do
    assert {:ok, pid} = Squad.start_link([])

    assert Squad.get(pid) == %Squad{
             owner: nil,
             members: [],
             state: {:lobby, %Lobby{players: [], ready: false}}
           }

    assert :error = GenServer.call(pid, :start_game)

    # p1 joins

    assert {:ok, _} = Squad.connect(pid, "p1", "Player 1")

    lobby = %Lobby{players: [{"p1", %Lobby.Player{name: "Player 1"}}], ready: false}

    assert Squad.get(pid) == %Squad{
             owner: "p1",
             members: ["p1"],
             state: {:lobby, lobby}
           }

    # p2 joins

    assert {:ok, _} = Squad.connect(pid, "p2", "Player 2")

    lobby = %Lobby{
      players: [
        {"p1", %Lobby.Player{name: "Player 1"}},
        {"p2", %Lobby.Player{name: "Player 2"}}
      ],
      ready: true
    }

    assert Squad.get(pid) == %Squad{
             owner: "p1",
             members: ["p1", "p2"],
             state: {:lobby, lobby}
           }

    # p3 joins

    assert {:ok, _} = Squad.connect(pid, "p3", "Player 3")

    lobby = %Lobby{
      players: [
        {"p1", %Lobby.Player{name: "Player 1"}},
        {"p2", %Lobby.Player{name: "Player 2"}},
        {"p3", %Lobby.Player{name: "Player 3"}}
      ],
      ready: true
    }

    assert Squad.get(pid) == %Squad{
             owner: "p1",
             members: ["p1", "p2", "p3"],
             state: {:lobby, lobby}
           }

    # p1 leaves

    assert {:ok, _} = Squad.disconnect(pid, "p1")

    lobby = %Lobby{
      players: [
        {"p2", %Lobby.Player{name: "Player 2"}},
        {"p3", %Lobby.Player{name: "Player 3"}}
      ],
      ready: true
    }

    assert Squad.get(pid) == %Squad{
             owner: "p2",
             members: ["p2", "p3"],
             state: {:lobby, lobby}
           }

    # start

    assert :error = GenServer.call(pid, {"p3", :start_game})

    assert {:ok, _} = GenServer.call(pid, {"p2", :start_game})

    %{state: {:game, game}} = Squad.get(pid)

    assert game.__struct__ == Game
  end
end
