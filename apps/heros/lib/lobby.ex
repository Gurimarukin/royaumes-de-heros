defmodule Heros.Lobby do
  alias Heros.Lobby
  alias Heros.Lobby.Player
  alias Heros.Utils.{KeyList, Option}

  @type t :: %__MODULE__{
          owner: nil | Player.id(),
          players: list({Player.id(), Player.t()})
        }
  @enforce_keys [:owner, :players]
  defstruct [:owner, :players]

  def empty?(lobby) do
    Enum.empty?(lobby.players)
  end

  def create(player_id, player_name) do
    %Lobby{
      owner: player_id,
      players: [{player_id, Player.from_name(player_name)}]
    }
  end

  def join(lobby, player_id, player_name) do
    case KeyList.find(lobby.players, player_id) do
      nil ->
        %{lobby | players: lobby.players ++ [{player_id, Player.from_name(player_name)}]}
        |> Option.some()

      _ ->
        Option.none()
    end
  end

  def leave(lobby, player_id) do
    with_member(lobby.players, player_id, fn _player ->
      players = lobby.players |> KeyList.delete(player_id)
      lobby = %{lobby | players: players}

      if player_id == lobby.owner do
        case players do
          [] -> %{lobby | owner: nil}
          [{id, _} | _] -> %{lobby | owner: id}
        end
      else
        lobby
      end
      |> Option.some()
    end)
  end

  defp with_member(list, key, f) do
    KeyList.find(list, key)
    |> Option.from_nilable()
    |> Option.chain(f)
  end
end
