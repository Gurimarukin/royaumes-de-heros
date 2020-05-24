defmodule Heros.Cards.Card do
  alias Heros.Cards.{Card, Guild, Imperial, Necros, Wild}

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

  @spec with_id(atom, integer) :: list({Card.id(), Card.t()})
  def with_id(key, n \\ 1) do
    List.duplicate(
      get(key),
      n
    )
    |> Enum.map(&{UUID.uuid1(:hex), &1})
  end

  @spec price(atom) :: nil | integer
  def price(:gem), do: 2

  def price(key) do
    Guild.price(key) ||
      Imperial.price(key) ||
      Necros.price(key) ||
      Wild.price(key)
  end
end
