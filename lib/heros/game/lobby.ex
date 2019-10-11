defmodule Heros.Game.Lobby do
  defstruct name: "Nouvelle partie",
            max_players: 4,
            is_public: false,
            is_ready: false,
            admin: nil

  alias Heros.Utils
  alias Heros.Game.Stage

  @behaviour Stage

  def rename(game, name) do
    GenServer.call(game, {:update, {:rename, name}})
  end

  def toggle_public(game) do
    GenServer.call(game, {:update, :toggle_public})
  end

  def start(game) do
    GenServer.call(game, {:update, :start})
  end

  defp is_admin(session_id, game), do: game.lobby.admin == session_id

  @impl Stage
  def projection_for_session(_session_id, game) do
    %{
      stage: game.stage,
      name: game.lobby.name,
      is_public: game.lobby.is_public,
      players:
        Enum.map(game.users, fn {id, session} ->
          %{
            id: id,
            name: session.user_name,
            is_admin: is_admin(id, game)
          }
        end),
      max_players: game.lobby.max_players,
      is_ready: game.lobby.is_ready
    }
  end

  @impl Stage
  def handle_call(_request, _from, _game),
    do: raise(MatchError, message: "no match of handle_call/3")

  @impl Stage
  def handle_update({:rename, name}, _from, game) do
    {:reply, :ok, put_in(game.lobby.name, name)}
  end

  def handle_update(:toggle_public, _from, game) do
    {:reply, :ok, update_in(game.lobby.is_public, &(not &1))}
  end

  def handle_update(:start, _from, game) do
    {:reply, :ok, Heros.Game.Match.start_game(game)}
  end

  @impl Stage
  def on_update(response) do
    Utils.map_call_response(
      response,
      &(remove_disconnected_users(&1)
        |> update_admin()
        |> update_is_ready())
    )
  end

  defp remove_disconnected_users(game) do
    users =
      Enum.reduce(game.users, game.users, fn {id, user}, users ->
        if MapSet.size(user.connected_views) == 0, do: Map.delete(users, id), else: users
      end)

    put_in(game.users, users)
  end

  defp update_admin(game) do
    admin =
      case game.users[game.lobby.admin] do
        nil -> List.first(Map.keys(game.users))
        _ -> game.lobby.admin
      end

    put_in(game.lobby.admin, admin)
  end

  defp update_is_ready(game) do
    put_in(game.lobby.is_ready, map_size(game.users) >= 2)
  end
end
