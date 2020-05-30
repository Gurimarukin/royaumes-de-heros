defmodule Heros.LobbyTest do
  use ExUnit.Case, async: true

  alias Heros.Lobby
  alias Heros.Lobby.Player

  test "lobby" do
    lobby = Lobby.create("p1", "Player 1")

    assert lobby == %Lobby{
             owner: "p1",
             players: [{"p1", %Player{name: "Player 1"}}]
           }

    assert :error = Lobby.join(lobby, "p1", "Player1")

    assert {:ok, lobby} = Lobby.join(lobby, "p2", "Player 2")

    assert lobby == %Lobby{
             owner: "p1",
             players: [{"p1", %Player{name: "Player 1"}}, {"p2", %Player{name: "Player 2"}}]
           }

    assert :error = Lobby.leave(lobby, "p3")

    assert {:ok, lobby} = Lobby.join(lobby, "p3", "Player 3")
    assert {:ok, lobby} = Lobby.leave(lobby, "p3")
    assert {:ok, lobby} = Lobby.leave(lobby, "p1")

    assert lobby == %Lobby{
             owner: "p2",
             players: [{"p2", %Player{name: "Player 2"}}]
           }

    assert {:ok, lobby} = Lobby.leave(lobby, "p2")

    assert lobby == %Lobby{owner: nil, players: []}
    assert Lobby.empty?(lobby)
  end
end
