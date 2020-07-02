defmodule Heros.LobbyTest do
  use ExUnit.Case, async: true

  alias Heros.Lobby
  alias Heros.Lobby.Player

  test "encode" do
    assert Jason.encode!(%Lobby{
             players: [{"p1", %Player{}}],
             ready: true
           })
  end

  test "lobby" do
    lobby = Lobby.empty()

    assert lobby == %Lobby{players: [], ready: false}

    assert {:ok, lobby} = Lobby.join(lobby, "p1")

    assert lobby == %Lobby{
             players: [{"p1", %Player{}}],
             ready: false
           }

    assert :error = Lobby.join(lobby, "p1")

    assert {:ok, lobby} = Lobby.join(lobby, "p2")

    assert lobby == %Lobby{
             players: [{"p1", %Player{}}, {"p2", %Player{}}],
             ready: true
           }

    assert :error = Lobby.leave(lobby, "p3")

    assert {:ok, lobby} = Lobby.join(lobby, "p3")

    assert lobby == %Lobby{
             players: [
               {"p1", %Player{}},
               {"p2", %Player{}},
               {"p3", %Player{}}
             ],
             ready: true
           }

    assert {:ok, lobby} = Lobby.leave(lobby, "p3")
    assert {:ok, lobby} = Lobby.leave(lobby, "p1")

    assert lobby == %Lobby{
             players: [{"p2", %Player{}}],
             ready: false
           }

    assert {:ok, lobby} = Lobby.leave(lobby, "p2")

    assert lobby == %Lobby{players: [], ready: false}
    assert Lobby.empty?(lobby)
  end
end
