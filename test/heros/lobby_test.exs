defmodule Heros.LobbyTest do
  use ExUnit.Case, async: true

  alias Heros.Lobby
  alias Heros.Lobby.Player

  test "encode" do
    assert Jason.encode!(%Lobby{
             players: [{"p1", %Player{name: "Player 1"}}],
             ready: true
           })
  end

  test "lobby" do
    lobby = Lobby.empty()

    assert lobby == %Lobby{players: [], ready: false}

    assert {:ok, lobby} = Lobby.join(lobby, "p1", "Player 1")

    assert lobby == %Lobby{
             players: [{"p1", %Player{name: "Player 1"}}],
             ready: false
           }

    assert :error = Lobby.join(lobby, "p1", "Player1")

    assert {:ok, lobby} = Lobby.join(lobby, "p2", "Player 2")

    assert lobby == %Lobby{
             players: [{"p1", %Player{name: "Player 1"}}, {"p2", %Player{name: "Player 2"}}],
             ready: true
           }

    assert :error = Lobby.leave(lobby, "p3")

    assert {:ok, lobby} = Lobby.join(lobby, "p3", "Player 3")

    assert lobby == %Lobby{
             players: [
               {"p1", %Player{name: "Player 1"}},
               {"p2", %Player{name: "Player 2"}},
               {"p3", %Player{name: "Player 3"}}
             ],
             ready: true
           }

    assert {:ok, lobby} = Lobby.leave(lobby, "p3")
    assert {:ok, lobby} = Lobby.leave(lobby, "p1")

    assert lobby == %Lobby{
             players: [{"p2", %Player{name: "Player 2"}}],
             ready: false
           }

    assert {:ok, lobby} = Lobby.leave(lobby, "p2")

    assert lobby == %Lobby{players: [], ready: false}
    assert Lobby.empty?(lobby)
  end
end
