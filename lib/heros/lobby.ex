defmodule Heros.Lobby do
  alias Heros.Lobby
  alias Heros.Lobby.Player
  alias Heros.Utils.{KeyList, Option}

  @type t :: %__MODULE__{
          players: list({Player.id(), Player.t()}),
          ready: boolean
        }
  @enforce_keys [:players, :ready]
  @derive Jason.Encoder
  defstruct [:players, :ready]

  def empty?(lobby) do
    Enum.empty?(lobby.players)
  end

  def empty do
    %Lobby{players: [], ready: false}
  end

  def join(lobby, player_id) do
    case KeyList.find(lobby.players, player_id) do
      nil ->
        %{lobby | players: lobby.players ++ [{player_id, Player.empty()}]}
        |> update_ready()
        |> Option.some()

      _ ->
        Option.none()
    end
  end

  def leave(lobby, player_id) do
    with_member(lobby.players, player_id, fn _player ->
      players = lobby.players |> KeyList.delete(player_id)

      %{lobby | players: players}
      |> update_ready()
      |> Option.some()
    end)
  end

  defp update_ready(lobby) do
    %{lobby | ready: 2 <= length(lobby.players)}
  end

  defp with_member(list, key, f) do
    KeyList.find(list, key)
    |> Option.from_nilable()
    |> Option.chain(f)
  end
end
