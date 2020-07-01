defmodule Heros.Squad.Member do
  alias Heros.Squad.Member

  @type t :: %__MODULE__{
          last_seen: integer(),
          name: String.t(),
          sockets: MapSet.t(pid)
        }
  @enforce_keys [:last_seen, :name, :sockets]
  defstruct [:last_seen, :name, :sockets]

  def init(name, socket) do
    %Member{
      last_seen: System.system_time(:millisecond),
      name: name,
      sockets: MapSet.new([socket])
    }
  end

  def put_socket(member, socket) do
    %{
      member
      | last_seen: System.system_time(:millisecond),
        sockets: member.sockets |> MapSet.put(socket)
    }
  end
end
