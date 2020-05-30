defmodule Heros.Squad do
  alias Heros.{Game, Lobby, Squad}
  alias Heros.Utils.{KeyList, Option}

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

  def init({player_id, player_name, subscribe}) do
    {:ok,
     %Squad{
       members: [{player_id, [subscribe]}],
       state: {:lobby, Lobby.create(player_id, player_name)}
     }}
  end

  def handle_call(:start_game, _from, squad) do
    case squad.state do
      {:lobby, lobby} ->
        if lobby.ready do
          start_game(lobby)
          |> Option.map(fn game -> %{squad | state: {:game, game}} end)
        else
          Option.none()
        end

      _ ->
        Option.none()
    end
    |> to_reply(squad)
  end

  def handle_call({:join, player_id, player_name, subscribe}, _from, squad) do
    case squad.state do
      {:lobby, lobby} ->
        Lobby.join(lobby, player_id, player_name)
        |> Option.map(fn lobby ->
          %{
            squad
            | members: squad.members ++ [{player_id, [subscribe]}],
              state: {:lobby, lobby}
          }
        end)

      _ ->
        Option.none()
    end
    |> to_reply(squad)
  end

  def handle_call(message, from, squad) do
    case squad.state do
      {:lobby, lobby} ->
        Lobby.Helpers.handle_call(message, from, lobby)
        |> Option.map(&%{squad | state: {:lobby, &1}})

      {:game, game} ->
        Game.Helpers.handle_call(message, from, game)
        |> Option.map(&%{squad | state: {:game, &1}})
    end
    |> to_reply(squad)
  end

  defp start_game(lobby) do
    lobby.players
    |> Enum.map(fn {id, _} -> id end)
    |> Game.init_from_players()
  end

  defp to_reply({:ok, squad}, _) do
    # broadcast state
    # TODO: projection
    squad.members
    |> KeyList.map(fn subscribtions ->
      subscribtions |> Enum.map(& &1.(squad.state))
    end)

    {:reply, {:ok, squad.state}, squad}
  end

  defp to_reply(:error, squad), do: {:reply, :error, squad}
end
