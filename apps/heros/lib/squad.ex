defmodule Heros.Squad do
  alias Heros.{Game, Lobby, Squad}

  use GenServer, restart: :temporary

  @type t :: %__MODULE__{
          members: list({Player.id(), list((any -> any))}),
          state: {:lobby, Lobby.t()} | {:game, Game.t()}
        }
  @enforce_keys [:members, :state]
  defstruct [:members, :state]

  def start_link(player_id, player_name, subscribe) do
    GenServer.start_link(__MODULE__, {player_id, player_name, subscribe})
  end

  def get(squad) do
    GenServer.call(squad, :get)
  end

  def init({player_id, player_name, subscribe}) do
    {:ok,
     %Squad{
       members: [{player_id, [subscribe]}],
       state: {:lobby, Lobby.create(player_id, player_name)}
     }}
  end

  def handle_call(:get, _from, squad) do
    {:reply, squad, squad}
  end
end
