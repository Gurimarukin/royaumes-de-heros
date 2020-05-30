defmodule Heros.Lobby.Player do
  alias Heros.Lobby.Player

  @type t :: %__MODULE__{
          name: String.t()
        }
  @enforce_keys [:name]
  defstruct [:name]

  def from_name(name) do
    %Player{
      name: name
    }
  end
end
