defmodule Heros.SquadTest do
  use ExUnit.Case, async: true

  alias Heros.{Game, Lobby, Squad}
  alias Heros.Squad.Member

  test "create squad" do
    assert {:ok, pid} = Squad.start_link([])

    assert Squad.get(pid) == %Squad{
             owner: nil,
             members: [],
             state: {:lobby, %Lobby{players: [], ready: false}}
           }

    assert :error = GenServer.call(pid, :start_game)

    # p1 joins

    assert {:ok, {squad, {"p1", :joined}}} = Squad.connect(pid, "p1", "Player 1", :p1_1)

    lobby = %Lobby{players: [{"p1", %Lobby.Player{name: "Player 1"}}], ready: false}

    assert Squad.get(pid) == squad

    assert squad == %Squad{
             owner: "p1",
             members: [{"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_1])}}],
             state: {:lobby, lobby}
           }

    # p1 joins again

    assert {:ok, {_, nil}} = Squad.connect(pid, "p1", "whatever", :p1_1)

    assert Squad.get(pid) == %Squad{
             owner: "p1",
             members: [{"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_1])}}],
             state: {:lobby, lobby}
           }

    # with other pid
    assert {:ok, {_, nil}} = Squad.connect(pid, "p1", "whatever", :p1_2)

    assert Squad.get(pid) == %Squad{
             owner: "p1",
             members: [{"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_1, :p1_2])}}],
             state: {:lobby, lobby}
           }

    # p2 joins

    assert {:ok, {_, {"p2", :joined}}} = Squad.connect(pid, "p2", "Player 2", :p2_1)

    lobby = %Lobby{
      players: [
        {"p1", %Lobby.Player{name: "Player 1"}},
        {"p2", %Lobby.Player{name: "Player 2"}}
      ],
      ready: true
    }

    assert Squad.get(pid) == %Squad{
             owner: "p1",
             members: [
               {"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_1, :p1_2])}},
               {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1])}}
             ],
             state: {:lobby, lobby}
           }

    # p3 joins

    assert {:ok, {_, {"p3", :joined}}} = Squad.connect(pid, "p3", "Player 3", :p3)

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
             members: [
               {"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_1, :p1_2])}},
               {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1])}},
               {"p3", %Member{name: "Player 3", sockets: MapSet.new([:p3])}}
             ],
             state: {:lobby, lobby}
           }

    # p1 leaves

    assert {:ok, {_, nil}} = Squad.disconnect(pid, "p1", :p3)
    assert {:ok, {_, nil}} = Squad.disconnect(pid, "p1", :p1_1)

    assert Squad.get(pid) == %Squad{
             owner: "p1",
             members: [
               {"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_2])}},
               {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1])}},
               {"p3", %Member{name: "Player 3", sockets: MapSet.new([:p3])}}
             ],
             state: {:lobby, lobby}
           }

    assert {:ok, {_, {"p1", :left}}} = Squad.disconnect(pid, "p1", :p1_2)

    lobby = %Lobby{
      players: [
        {"p2", %Lobby.Player{name: "Player 2"}},
        {"p3", %Lobby.Player{name: "Player 3"}}
      ],
      ready: true
    }

    assert Squad.get(pid) == %Squad{
             owner: "p2",
             members: [
               {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1])}},
               {"p3", %Member{name: "Player 3", sockets: MapSet.new([:p3])}}
             ],
             state: {:lobby, lobby}
           }

    # start

    assert :error = GenServer.call(pid, {"p3", "start_game"})

    assert {:ok, {_, {"p2", :start_game}}} = GenServer.call(pid, {"p2", "start_game"})

    %{state: {:game, game}} = Squad.get(pid)

    assert game.__struct__ == Game

    # p1 can't rejoin as game started

    assert :error = Squad.connect(pid, "p1", "Player 1", :p1_1)

    # but p2 can
    assert {:ok, {_, nil}} = Squad.connect(pid, "p2", "whatever", :p2_2)

    assert Squad.get(pid) == %Squad{
             owner: "p2",
             members: [
               {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1, :p2_2])}},
               {"p3", %Member{name: "Player 3", sockets: MapSet.new([:p3])}}
             ],
             state: {:game, game}
           }

    # when p3 leaves, doesn't change game

    assert {:ok, {_, {"p3", :disconnected}}} = Squad.disconnect(pid, "p3", :p3)

    assert Squad.get(pid) == %Squad{
             owner: "p2",
             members: [
               {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1, :p2_2])}},
               {"p3", %Member{name: "Player 3", sockets: MapSet.new()}}
             ],
             state: {:game, game}
           }
  end
end
