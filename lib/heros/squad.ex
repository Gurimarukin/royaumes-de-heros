defmodule Heros.Squad do
  alias Heros.{Game, Lobby, Squad}
  alias Heros.Squad.Member
  alias Heros.Utils.{KeyList, Option}

  use GenServer, restart: :temporary

  require Logger

  @type t :: %__MODULE__{
          owner: nil | Player.id(),
          members: list({Player.id(), Member.t()}),
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

  def connect(squad, member_id, player_name, socket) do
    GenServer.call(squad, {:connect, member_id, player_name, socket})
  end

  def disconnect(squad, member_id, socket) do
    GenServer.call(squad, {:disconnect, member_id, socket})
  end

  def init(:ok) do
    {:ok, %Squad{owner: nil, members: [], state: {:lobby, Lobby.empty()}}}
  end

  def handle_call(:get, _from, squad) do
    {:reply, squad, squad}
  end

  def handle_call({player_id, "start_game"}, _from, squad) do
    case squad.state do
      {:lobby, lobby} ->
        if lobby.ready and squad.owner == player_id do
          start_game(lobby)
          |> Option.map(fn game -> %{squad | state: {:game, game}} end)
          |> Option.map(&{&1, {player_id, :start_game}})
        else
          Option.none()
        end

      _ ->
        Option.none()
    end
    |> to_reply(squad)
  end

  def handle_call({:connect, member_id, player_name, socket}, _from, squad) do
    case squad.state do
      {:lobby, lobby} ->
        case KeyList.find(squad.members, member_id) do
          nil ->
            Logger.debug(~s"Squad #{inspect(self())}: #{player_name} joined")

            Lobby.join(lobby, member_id, player_name)
            |> Option.map(fn lobby ->
              members = squad.members ++ [{member_id, Member.init(player_name, socket)}]
              owner = squad.owner || member_id
              %{squad | owner: owner, members: members, state: {:lobby, lobby}}
            end)
            |> Option.map(&{&1, {member_id, :joined}})

          _member ->
            squad
            |> update_member(member_id, &Member.put_socket(&1, socket))
            |> Option.some()
            |> Option.map(&{&1, nil})
        end

      {:game, _game} ->
        with_member(squad.members, member_id, fn member_before ->
          squad
          |> update_member(member_id, &Member.put_socket(&1, socket))
          |> Option.some()
          |> Option.map(
            &{&1,
             if MapSet.size(member_before.sockets) == 0 do
               {member_id, :reconnected}
             else
               nil
             end}
          )
        end)
    end
    |> to_reply(squad)
  end

  def handle_call({:disconnect, member_id, socket}, _from, squad) do
    with_member(squad.members, member_id, fn member ->
      Logger.debug(~s"Squad #{inspect(self())}: #{member_id} disconected #{inspect(socket)}")

      sockets = MapSet.delete(member.sockets, socket)

      if MapSet.size(sockets) == 0 do
        Logger.debug(~s"Squad #{inspect(self())}: no more connections for #{member_id}")
        Logger.debug(~s"Squad #{inspect(self())}: #{member_id} left")

        case squad.state do
          {:lobby, lobby} ->
            Lobby.leave(lobby, member_id)
            |> Option.map(fn lobby ->
              %{squad | state: {:lobby, lobby}}
              |> delete_member(member_id)
              |> update_owner(member_id)
            end)
            |> Option.map(&{&1, {member_id, :left}})

          state ->
            %{squad | state: state}
            |> update_member(member_id, &%{&1 | sockets: sockets})
            |> update_owner(member_id)
            |> Option.some()
            |> Option.map(&{&1, {member_id, :disconnected}})
        end
      else
        squad
        |> update_member(member_id, &%{&1 | sockets: sockets})
        |> Option.some()
        |> Option.map(&{&1, nil})
      end
    end)
    |> to_reply(squad)
  end

  def handle_call(message, from, squad) do
    res =
      case squad.state do
        {:lobby, lobby} ->
          Lobby.Helpers.handle_call(message, from, lobby)
          |> Option.map(fn {lobby, event} -> {%{squad | state: {:lobby, lobby}}, event} end)

        {:game, game} ->
          Game.Helpers.handle_call(message, from, game)
          |> Option.map(fn {game, event} -> {%{squad | state: {:game, game}}, event} end)
      end

    if res == :error do
      Logger.debug(~s"Squad: #{elem(squad.state, 0)} couldn't handle message #{inspect(message)}")
    end

    res
    |> to_reply(squad)
  end

  defp start_game(lobby) do
    lobby.players
    |> Enum.map(fn {id, _} -> id end)
    |> Game.init_from_players()
  end

  defp delete_member(squad, member_id) do
    %{squad | members: squad.members |> KeyList.delete(member_id)}
  end

  defp update_owner(squad, member_id) do
    non_empty_members =
      squad.members |> Enum.filter(fn {_, member} -> MapSet.size(member.sockets) != 0 end)

    owner =
      if squad.owner == member_id do
        case non_empty_members do
          [] -> nil
          [head | _] -> head |> elem(0)
        end
      else
        squad.owner
      end

    %{squad | owner: owner}
  end

  defp update_member(squad, member_id, f) do
    %{squad | members: squad.members |> KeyList.update(member_id, f)}
  end

  defp to_reply({:ok, {squad, message}}, _old_squad), do: {:reply, {:ok, {squad, message}}, squad}
  defp to_reply(:error, squad), do: {:reply, :error, squad}

  defp with_member(list, key, f) do
    KeyList.find(list, key)
    |> Option.from_nilable()
    |> Option.chain(f)
  end
end
