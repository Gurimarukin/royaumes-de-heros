defmodule Heros.Squad do
  alias Heros.{Game, Lobby, Squad}
  alias Heros.Squad.Member
  alias Heros.Utils.{KeyList, Option, ProcessUtils}

  use GenServer, restart: :temporary

  require Logger

  @squad_timeout Application.get_env(:heros, :squad_timeout)

  @type t :: %__MODULE__{
          broadcast_update: (any -> any),
          owner: nil | Player.id(),
          members: list({Player.id(), Member.t()}),
          state: {:lobby, Lobby.t()} | {:game, Game.t()}
        }
  @enforce_keys [:broadcast_update, :owner, :members, :state]
  defstruct [:broadcast_update, :owner, :members, :state]

  def start_link(opts) do
    broadcast_update = opts[:broadcast_update]

    if is_function(broadcast_update, 1) do
      GenServer.start_link(__MODULE__, broadcast_update, opts)
    else
      raise ArgumentError, message: "invalid argument broadcast_update"
    end
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

  def disconnect(squad, socket) do
    GenServer.call(squad, {:disconnect, socket})
  end

  def init(broadcast_update) do
    {:ok,
     %Squad{
       broadcast_update: broadcast_update,
       owner: nil,
       members: [],
       state: {:lobby, Lobby.empty()}
     }}
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
          |> Option.map(&{&1, {KeyList.find(names(&1), player_id), :start_game}})
        else
          Option.none()
        end

      {:game, _game} ->
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
            |> Option.map(&{&1, {KeyList.find(names(&1), member_id), :lobby_joined}})

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
               {KeyList.find(names(&1), member_id), :game_reconnected}
             else
               nil
             end}
          )
        end)
    end
    |> Option.map(fn res ->
      Process.monitor(socket)
      res
    end)
    |> to_reply(squad)
  end

  def handle_call({:disconnect, socket}, _from, squad) do
    # with_member(squad.members, member_id, fn member ->
    #   Logger.debug(~s"Squad #{inspect(self())}: #{member_id} disconnected #{inspect(socket)}")

    #   sockets = MapSet.delete(member.sockets, socket)

    #   if MapSet.size(sockets) == 0 do
    #     Logger.debug(~s"Squad #{inspect(self())}: no more connections for #{member_id}")
    #     Logger.debug(~s"Squad #{inspect(self())}: #{member_id} left")

    #     case squad.state do
    #       {:lobby, lobby} ->
    #         Lobby.leave(lobby, member_id)
    #         |> Option.map(fn lobby ->
    #           %{squad | state: {:lobby, lobby}}
    #           |> delete_member(member_id)
    #           |> update_owner(member_id)
    #         end)
    #         |> Option.map(&{&1, {KeyList.find(names(squad), member_id), :lobby_left}})

    #       state ->
    #         %{squad | state: state}
    #         |> update_member(member_id, &%{&1 | sockets: sockets})
    #         |> update_owner(member_id)
    #         |> Option.some()
    #         |> Option.map(&{&1, {KeyList.find(names(squad), member_id), :game_disconnected}})
    #     end
    #   else
    #     squad
    #     |> update_member(member_id, &%{&1 | sockets: sockets})
    #     |> Option.some()
    #     |> Option.map(&{&1, nil})
    #   end
    # end)
    # |> to_reply(squad)

    KeyList.find_where(squad.members, &MapSet.member?(&1.sockets, socket))
    |> Option.from_nilable()
    |> Option.map(fn member_id ->
      members =
        KeyList.update(squad.members, member_id, fn member ->
          Logger.debug(
            ~s"Squad #{inspect(self())}: #{member.name} disconnected #{inspect(socket)}"
          )

          sockets = MapSet.delete(member.sockets, socket)

          if MapSet.size(sockets) == 0 do
            Logger.debug(~s"Squad #{inspect(self())}: no more connections for #{member.name}")

            ProcessUtils.send_self_after(@squad_timeout, {:check_reconnected, member_id})
          end

          %{member | sockets: sockets}
        end)

      {%{squad | members: members}, nil}
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
          names = squad.members |> KeyList.map(& &1.name)

          Game.Helpers.handle_call(message, from, game, names)
          |> Option.map(fn {game, event} -> {%{squad | state: {:game, game}}, event} end)
      end

    if res == :error do
      Logger.debug(~s"Squad: #{elem(squad.state, 0)} couldn't handle message #{inspect(message)}")
    end

    res
    |> to_reply(squad)
  end

  def handle_info({:check_reconnected, member_id}, squad) do
    case KeyList.find(squad.members, member_id) do
      nil ->
        {:noreply, squad}

      member ->
        Logger.debug(~s"Squad #{inspect(self())}: #{member.name} left")

        res =
          case squad.state do
            {:lobby, lobby} ->
              Lobby.leave(lobby, member_id)
              |> Option.map(fn lobby ->
                squad =
                  %{squad | state: {:lobby, lobby}}
                  |> delete_member(member_id)
                  |> update_owner(member_id)

                {squad, {member.name, :lobby_left}}
              end)

            {:game, _game} ->
              {squad, {member.name, :game_disconnected}}
              |> Option.some()
          end

        case res do
          {:ok, {squad, message}} ->
            squad.broadcast_update.({squad, message})
            {:noreply, squad}

          :error ->
            {:noreply, squad}
        end

        # game =
        #   if System.system_time(:millisecond) >= user.last_seen + 10000 do
        #     Logger.debug(~s"Game #{game.lobby.name}: #{user.user_name} disconnected")
        #     update_in(game.users, &Utils.keydelete(&1, id_user))
        #   else
        #     Logger.debug(~s"Game #{game.lobby.name}: #{user.user_name} reconnected in time")
        #     game
        #   end
    end
  end

  def handle_info({:DOWN, _ref, :process, socket, _reason}, squad) do
    case handle_call({:disconnect, socket}, nil, squad) do
      {:stop, reason, _reply, squad} -> {:stop, reason, squad}
      {:reply, _reply, squad} -> {:noreply, squad}
    end
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

  defp names(squad), do: squad.members |> KeyList.map(& &1.name)
end
