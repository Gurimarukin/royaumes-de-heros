defmodule Heros.SquadTest do
  use ExUnit.Case, async: true

  alias Heros.{Lobby, Squad}
  alias Heros.Squad.Member

  defmodule SimpleGenServer do
    use GenServer, restart: :temporary

    def start_link(opts \\ []) do
      GenServer.start_link(__MODULE__, :ok, opts)
    end

    def get(server) do
      GenServer.call(server, :get)
    end

    def init(:ok) do
      {:ok, nil}
    end

    def handle_call(:get, _from, state) do
      {:reply, state, state}
    end

    def handle_info(msg, _state) do
      {:noreply, msg}
    end
  end

  defp agent do
    {:ok, agent} = Agent.start_link(fn -> [] end)

    %{
      get: fn -> Agent.get(agent, fn l -> l end) end,
      call: fn msg -> Agent.update(agent, fn l -> l ++ [msg] end) end
    }
  end

  test "create squad" do
    %{call: call} = agent()

    {:ok, squad_pid} = Squad.start_link(broadcast_update: call)

    assert Squad.get(squad_pid) == %Squad{
             broadcast_update: call,
             owner: nil,
             members: [],
             state: {:lobby, %Lobby{players: [], ready: false}}
           }
  end

  test "player can join" do
    %{call: call} = agent()
    {:ok, p1} = SimpleGenServer.start_link()

    {:ok, squad_pid} = Squad.start_link(broadcast_update: call)

    {:ok, {squad, {"Player 1", :lobby_joined}}} = Squad.connect(squad_pid, "p1", "Player 1", p1)

    assert Squad.get(squad_pid) == squad

    assert squad == %Squad{
             broadcast_update: call,
             owner: "p1",
             members: [{"p1", %Member{name: "Player 1", sockets: MapSet.new([p1])}}],
             state:
               {:lobby, %Lobby{players: [{"p1", %Lobby.Player{name: "Player 1"}}], ready: false}}
           }
  end

  test "player can connect multiple times" do
    %{call: call} = agent()
    {:ok, p1_1} = SimpleGenServer.start_link()
    {:ok, p1_2} = SimpleGenServer.start_link()

    {:ok, squad_pid} = Squad.start_link(broadcast_update: call)

    {:ok, {_, {"Player 1", :lobby_joined}}} = Squad.connect(squad_pid, "p1", "Player 1", p1_1)
    {:ok, {squad, nil}} = Squad.connect(squad_pid, "p1", "whatever", p1_2)

    assert squad == %Squad{
             broadcast_update: call,
             owner: "p1",
             members: [{"p1", %Member{name: "Player 1", sockets: MapSet.new([p1_1, p1_2])}}],
             state:
               {:lobby, %Lobby{players: [{"p1", %Lobby.Player{name: "Player 1"}}], ready: false}}
           }
  end

  test "socket crashes" do
    %{call: call} = agent()
    {:ok, p1} = SimpleGenServer.start_link()

    {:ok, squad_pid} = Squad.start_link(broadcast_update: call)

    {:ok, {_, {"Player 1", :lobby_joined}}} = Squad.connect(squad_pid, "p1", "Player 1", p1)

    GenServer.stop(p1)

    assert not Process.alive?(p1)

    assert Squad.get(squad_pid) == %Squad{
             broadcast_update: call,
             owner: "p1",
             members: [{"p1", %Member{name: "Player 1", sockets: MapSet.new()}}],
             state:
               {:lobby, %Lobby{players: [{"p1", %Lobby.Player{name: "Player 1"}}], ready: false}}
           }
  end

  test "member disconnects" do
    %{get: get, call: call} = agent()
    {:ok, p1} = SimpleGenServer.start_link()
    {:ok, p2} = SimpleGenServer.start_link()

    {:ok, squad_pid} = Squad.start_link(broadcast_update: call)

    {:ok, {_, {"Player 1", :lobby_joined}}} = Squad.connect(squad_pid, "p1", "Player 1", p1)
    {:ok, {squad, {"Player 2", :lobby_joined}}} = Squad.connect(squad_pid, "p2", "Player 2", p2)

    assert squad == %Squad{
             broadcast_update: call,
             owner: "p1",
             members: [
               {"p1", %Member{name: "Player 1", sockets: MapSet.new([p1])}},
               {"p2", %Member{name: "Player 2", sockets: MapSet.new([p2])}}
             ],
             state:
               {:lobby,
                %Lobby{
                  players: [
                    {"p1", %Lobby.Player{name: "Player 1"}},
                    {"p2", %Lobby.Player{name: "Player 2"}}
                  ],
                  ready: true
                }}
           }

    GenServer.stop(p1)

    Process.sleep(550)

    squad = %Squad{
      broadcast_update: call,
      owner: "p2",
      members: [{"p2", %Member{name: "Player 2", sockets: MapSet.new([p2])}}],
      state: {:lobby, %Lobby{players: [{"p2", %Lobby.Player{name: "Player 2"}}], ready: false}}
    }

    assert get.() == [{squad, {"Player 1", :lobby_left}}]

    assert Squad.get(squad_pid) == squad
  end

  test "member leaves" do
    %{get: get, call: call} = agent()
    {:ok, p1} = SimpleGenServer.start_link()
    {:ok, p2} = SimpleGenServer.start_link()

    {:ok, squad_pid} = Squad.start_link(broadcast_update: call)

    {:ok, {_, {"Player 1", :lobby_joined}}} = Squad.connect(squad_pid, "p1", "Player 1", p1)
    {:ok, {_, {"Player 2", :lobby_joined}}} = Squad.connect(squad_pid, "p2", "Player 2", p2)

    {:ok, {squad, {"Player 1", :lobby_left}}} = Squad.leave(squad_pid, "p1")

    assert get.() == []

    assert squad == %Squad{
             broadcast_update: call,
             owner: "p2",
             members: [{"p2", %Member{name: "Player 2", sockets: MapSet.new([p2])}}],
             state:
               {:lobby, %Lobby{players: [{"p2", %Lobby.Player{name: "Player 2"}}], ready: false}}
           }
  end
end

# defmodule Heros.SquadTest do
#   use ExUnit.Case, async: true

#   alias Heros.{Game, Lobby, Squad}
#   alias Heros.Squad.Member

#   test "create squad" do
#     assert {:ok, pid} = Squad.start_link([])

#     assert Squad.get(pid) == %Squad{
#              owner: nil,
#              members: [],
#              state: {:lobby, %Lobby{players: [], ready: false}}
#            }

#     assert :error = GenServer.call(pid, :start_game)

#     # p1 joins

#     assert {:ok, {squad, {"Player 1", :lobby_joined}}} =
#              Squad.connect(pid, "p1", "Player 1", :p1_1)

#     lobby = %Lobby{players: [{"p1", %Lobby.Player{name: "Player 1"}}], ready: false}

#     assert Squad.get(pid) == squad

#     assert squad == %Squad{
#              owner: "p1",
#              members: [{"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_1])}}],
#              state: {:lobby, lobby}
#            }

#     # p1 joins again

#     assert {:ok, {_, nil}} = Squad.connect(pid, "p1", "whatever", :p1_1)

#     assert Squad.get(pid) == %Squad{
#              owner: "p1",
#              members: [{"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_1])}}],
#              state: {:lobby, lobby}
#            }

#     # with other pid
#     assert {:ok, {_, nil}} = Squad.connect(pid, "p1", "whatever", :p1_2)

#     assert Squad.get(pid) == %Squad{
#              owner: "p1",
#              members: [{"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_1, :p1_2])}}],
#              state: {:lobby, lobby}
#            }

#     # p2 joins

#     assert {:ok, {_, {"Player 2", :lobby_joined}}} = Squad.connect(pid, "p2", "Player 2", :p2_1)

#     lobby = %Lobby{
#       players: [
#         {"p1", %Lobby.Player{name: "Player 1"}},
#         {"p2", %Lobby.Player{name: "Player 2"}}
#       ],
#       ready: true
#     }

#     assert Squad.get(pid) == %Squad{
#              owner: "p1",
#              members: [
#                {"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_1, :p1_2])}},
#                {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1])}}
#              ],
#              state: {:lobby, lobby}
#            }

#     # p3 joins

#     assert {:ok, {_, {"Player 3", :lobby_joined}}} = Squad.connect(pid, "p3", "Player 3", :p3)

#     lobby = %Lobby{
#       players: [
#         {"p1", %Lobby.Player{name: "Player 1"}},
#         {"p2", %Lobby.Player{name: "Player 2"}},
#         {"p3", %Lobby.Player{name: "Player 3"}}
#       ],
#       ready: true
#     }

#     assert Squad.get(pid) == %Squad{
#              owner: "p1",
#              members: [
#                {"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_1, :p1_2])}},
#                {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1])}},
#                {"p3", %Member{name: "Player 3", sockets: MapSet.new([:p3])}}
#              ],
#              state: {:lobby, lobby}
#            }

#     # p1 leaves

#     assert {:ok, {_, nil}} = Squad.disconnect(pid, "p1", :p3)
#     assert {:ok, {_, nil}} = Squad.disconnect(pid, "p1", :p1_1)

#     assert Squad.get(pid) == %Squad{
#              owner: "p1",
#              members: [
#                {"p1", %Member{name: "Player 1", sockets: MapSet.new([:p1_2])}},
#                {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1])}},
#                {"p3", %Member{name: "Player 3", sockets: MapSet.new([:p3])}}
#              ],
#              state: {:lobby, lobby}
#            }

#     assert {:ok, {_, {"Player 1", :lobby_left}}} = Squad.disconnect(pid, "p1", :p1_2)

#     lobby = %Lobby{
#       players: [
#         {"p2", %Lobby.Player{name: "Player 2"}},
#         {"p3", %Lobby.Player{name: "Player 3"}}
#       ],
#       ready: true
#     }

#     assert Squad.get(pid) == %Squad{
#              owner: "p2",
#              members: [
#                {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1])}},
#                {"p3", %Member{name: "Player 3", sockets: MapSet.new([:p3])}}
#              ],
#              state: {:lobby, lobby}
#            }

#     # start

#     assert :error = GenServer.call(pid, {"p3", "start_game"})

#     assert {:ok, {_, {"Player 2", :start_game}}} = GenServer.call(pid, {"p2", "start_game"})

#     %{state: {:game, game}} = Squad.get(pid)

#     assert game.__struct__ == Game

#     # p1 can't rejoin as game started

#     assert :error = Squad.connect(pid, "p1", "Player 1", :p1_1)

#     # but p2 can
#     assert {:ok, {_, nil}} = Squad.connect(pid, "p2", "whatever", :p2_2)

#     assert Squad.get(pid) == %Squad{
#              owner: "p2",
#              members: [
#                {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1, :p2_2])}},
#                {"p3", %Member{name: "Player 3", sockets: MapSet.new([:p3])}}
#              ],
#              state: {:game, game}
#            }

#     # when p3 leaves, doesn't change game

#     assert {:ok, {_, {"Player 3", :game_disconnected}}} = Squad.disconnect(pid, "p3", :p3)

#     assert Squad.get(pid) == %Squad{
#              owner: "p2",
#              members: [
#                {"p2", %Member{name: "Player 2", sockets: MapSet.new([:p2_1, :p2_2])}},
#                {"p3", %Member{name: "Player 3", sockets: MapSet.new()}}
#              ],
#              state: {:game, game}
#            }
#   end
# end
