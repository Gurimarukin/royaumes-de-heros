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

  @spec price(atom) :: nil | integer
  def price(:gem), do: 2

  def price(key) do
    Guild.price(key) ||
      Imperial.price(key) ||
      Necros.price(key) ||
      Wild.price(key)
  end

  @spec champion(atom) :: nil | {:not_guard | :guard, integer}
  def champion(key) do
    Guild.champion(key) ||
      Imperial.champion(key) ||
      Necros.champion(key) ||
      Wild.champion(key)
  end

  @spec is_champion(atom) :: boolean
  def is_champion(key), do: champion(key) != nil

  @spec is_guard(atom) :: boolean
  def is_guard(key) do
    case champion(key) do
      {:guard, _} -> true
      _ -> false
    end
  end

  @spec reset_state(Card.t()) :: Card.t()
  def reset_state(card) do
    %{
      card
      | expend_ability_used: false,
        ally_ability_used: false,
        sacrifice_ability_used: false
    }
  end

  @spec expend(Card.t()) :: Card.t()
  def expend(card), do: %{card | expend_ability_used: true}
end
