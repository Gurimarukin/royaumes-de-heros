defmodule Heros.Squad do
  alias Heros.Squad

  @type t :: %__MODULE__{
          users: list({Player.id(), list((any -> any))})
        }
  @enforce_keys [:users]
  defstruct [:users]

  def create(user_id, subscribe) do
    %Squad{
      users: [{user_id, [subscribe]}]
    }
  end
end
