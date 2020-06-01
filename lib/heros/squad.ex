defmodule Heros.Squad do
  alias Heros.{Game, Lobby, Squad}
  alias Heros.Utils.{KeyList, Option}

  use GenServer, restart: :temporary

  require Logger

  @type t :: %__MODULE__{
          owner: nil | Player.id(),
          members: list({Player.id(), MapSet.t(pid)}),
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
              members = squad.members ++ [{member_id, MapSet.new([socket])}]
              owner = squad.owner || member_id
              %{squad | owner: owner, members: members, state: {:lobby, lobby}}
            end)

          _sockets ->
            members = squad.members |> KeyList.update(member_id, &MapSet.put(&1, socket))
            Option.some(%{squad | members: members})
        end

      {:game, _game} ->
        with_member(squad.members, member_id, fn _sockets ->
          %{squad | members: squad.members |> KeyList.update(member_id, &MapSet.put(&1, socket))}
          |> Option.some()
        end)
    end
    |> to_reply(squad)
  end

  def handle_call({:disconnect, member_id, socket}, _from, squad) do
    with_member(squad.members, member_id, fn sockets ->
      Logger.debug(~s"Squad #{inspect(self())}: #{member_id} disconected #{inspect(socket)}")

      sockets = MapSet.delete(sockets, socket)

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

          state ->
            %{
              squad
              | state: state,
                members: squad.members |> KeyList.update(member_id, fn _ -> sockets end)
            }
            |> update_owner(member_id)
            |> Option.some()
        end
      else
        %{squad | members: squad.members |> KeyList.update(member_id, fn _ -> sockets end)}
        |> Option.some()
      end
    end)
    |> to_reply(squad)
  end

  def handle_call(message, from, squad) do
    Logger.debug(
      ~s"Squad: didn't handle message #{inspect(message)}; dispatching to #{elem(squad.state, 0)}"
    )

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

  defp delete_member(squad, member_id) do
    %{squad | members: squad.members |> KeyList.delete(member_id)}
  end

  defp update_owner(squad, member_id) do
    non_empty_members =
      squad.members |> Enum.filter(fn {_, sockets} -> MapSet.size(sockets) != 0 end)

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

  defp to_reply({:ok, squad}, _old_squad), do: {:reply, {:ok, squad}, squad}
  defp to_reply(:error, squad), do: {:reply, :error, squad}

  defp with_member(list, key, f) do
    KeyList.find(list, key)
    |> Option.from_nilable()
    |> Option.chain(f)
  end
end
