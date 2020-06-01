defmodule Heros.Squad do
  alias Heros.{Game, Lobby, Squad}
  alias Heros.Utils.{KeyList, Option}

  use GenServer, restart: :temporary

  @type t :: %__MODULE__{
          owner: nil | Player.id(),
          members: list({Player.id(), list((any -> any))}),
          state: {:lobby, Lobby.t()} | {:game, Game.t()}
        }
  @enforce_keys [:owner, :members, :state]
  defstruct [:owner, :members, :state]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get(squad) do
    GenServer.call(squad, :get)
  end

  def short(squad) do
    squad = %{state: {stage, _}} = GenServer.call(squad, :get)
    %{stage: stage, n_players: length(squad.members)}
  end

  def connect(squad, player_id, player_name) do
    GenServer.call(squad, {:connect, player_id, player_name})
  end

  def disconnect(squad, player_id) do
    GenServer.call(squad, {:disconnect, player_id})
  end

  def init(:ok) do
    {:ok, %Squad{owner: nil, members: [], state: {:lobby, Lobby.empty()}}}
  end

  def handle_call(:get, _from, squad) do
    {:reply, squad, squad}
  end

  def handle_call({player_id, :start_game}, _from, squad) do
    case squad.state do
      {:lobby, lobby} ->
        if lobby.ready and squad.owner == player_id do
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

  # TODO: remove join and leave
  def handle_call({:join, player_id, player_name, subscribe}, _from, squad) do
    case squad.state do
      {:lobby, lobby} ->
        Lobby.join(lobby, player_id, player_name)
        |> Option.map(fn lobby ->
          members = squad.members ++ [{player_id, [subscribe]}]
          owner = squad.owner || hd(members) |> elem(0)
          %{squad | owner: owner, members: members, state: {:lobby, lobby}}
        end)

      _ ->
        Option.none()
    end
    |> to_reply(squad)
  end

  def handle_call({:leave, player_id}, _from, squad) do
    case squad.state do
      {:lobby, lobby} ->
        Lobby.leave(lobby, player_id)
        |> Option.map(fn lobby ->
          members = squad.members |> KeyList.delete(player_id)

          owner =
            if squad.owner == player_id do
              case members do
                [] -> nil
                [head | _] -> head |> elem(0)
              end
            else
              squad.owner
            end

          %{squad | owner: owner, members: members, state: {:lobby, lobby}}
        end)

      _ ->
        Option.none()
    end
    |> to_reply(squad)
  end

  def handle_call({:connect, player_id, player_name}, _from, squad) do
    case squad.state do
      {:lobby, lobby} ->
        Lobby.join(lobby, player_id, player_name)
        |> Option.map(fn lobby ->
          members = squad.members ++ [player_id]
          owner = squad.owner || hd(members)
          %{squad | owner: owner, members: members, state: {:lobby, lobby}}
        end)

      _ ->
        Option.none()
    end
    |> to_reply(squad)
  end

  def handle_call({:disconnect, player_id}, _from, squad) do
    case squad.state do
      {:lobby, lobby} ->
        Lobby.leave(lobby, player_id)
        |> Option.map(fn lobby ->
          members = squad.members |> Enum.filter(&(&1 != player_id))

          owner =
            if squad.owner == player_id do
              case members do
                [] -> nil
                [head | _] -> head
              end
            else
              squad.owner
            end

          %{squad | owner: owner, members: members, state: {:lobby, lobby}}
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

  defp to_reply({:ok, squad}, _old_squad) do
    # if squad != old_squad do
    #   # broadcast state
    #   # TODO: projection
    #   squad.members
    #   |> KeyList.map(fn subscribtions ->
    #     subscribtions |> Enum.map(& &1.(squad.state))
    #   end)
    # end

    {:reply, {:ok, squad.state}, squad}
  end

  defp to_reply(:error, squad), do: {:reply, :error, squad}
end
