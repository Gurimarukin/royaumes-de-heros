defmodule Heros.Lobby.Player do
  alias Heros.Lobby.Player

  @type t :: %__MODULE__{}
  @enforce_keys []
  @derive Jason.Encoder
  defstruct []

  def empty, do: %Player{}
end
