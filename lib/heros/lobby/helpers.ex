defmodule Heros.Lobby.Helpers do
  alias Heros.Lobby
  alias Heros.Utils.Option

  def handle_call(_message, _from, _lobby), do: Option.none()
end
