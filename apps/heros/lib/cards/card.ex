defmodule Heros.Cards.Card do
  alias Heros.Cards.Card

  @type id :: binary

  @type t :: %{
          key: atom,
          expend_ability_used: boolean,
          ally_ability_used: boolean,
          sacrifice_ability_used: boolean
        }
  @enforce_keys [:key, :expend_ability_used, :ally_ability_used, :sacrifice_ability_used]
  defstruct [:key, :expend_ability_used, :ally_ability_used, :sacrifice_ability_used]

  def get(key) do
    %Card{
      key: key,
      expend_ability_used: false,
      ally_ability_used: false,
      sacrifice_ability_used: false
    }
  end

  @spec with_id(atom, number) :: list({Card.id(), Card.t()})
  def with_id(key, n \\ 1) do
    List.duplicate(
      get(key),
      n
    )
    |> Enum.map(&{UUID.uuid1(:hex), &1})
  end
end
