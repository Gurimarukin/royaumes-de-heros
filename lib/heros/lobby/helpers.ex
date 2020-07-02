defmodule Heros.Lobby.Helpers do
  alias Heros.Utils.{KeyList, Option}

  # def handle_call({player_id, "start_game"}, _from, game) do
  #   Lobby.(game, player_id, card_id)
  # end

  def handle_call(_message, _from, _lobby), do: Option.none()

  def project(lobby, squad, names) do
    %{
      owner: squad.owner,
      players:
        lobby.players
        |> Enum.map(fn {id, _} -> {id, %{name: KeyList.find(names, id)}} end),
      ready: lobby.ready
    }
  end
end
