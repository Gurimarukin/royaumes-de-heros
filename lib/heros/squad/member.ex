defmodule Heros.Squad.Member do
  alias Heros.Squad.Member

  @type t :: %__MODULE__{
          name: String.t(),
          sockets: MapSet.t(pid)
        }
  @enforce_keys [:name, :sockets]
  defstruct [:name, :sockets]

  def init(name, socket) do
    %Member{name: name, sockets: MapSet.new([socket])}
  end

  def put_socket(member, socket) do
    %{member | sockets: member.sockets |> MapSet.put(socket)}
  end
end
