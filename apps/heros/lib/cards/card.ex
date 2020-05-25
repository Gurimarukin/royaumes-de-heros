defmodule Heros.Cards.Card do
  alias Heros.Cards.{Card, Decks, Guild, Imperial, Necros, Wild}

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

  @spec cost(atom) :: nil | integer
  def cost(:gem), do: 2

  def cost(key) do
    Guild.cost(key) ||
      Imperial.cost(key) ||
      Necros.cost(key) ||
      Wild.cost(key)
  end

  @spec type(atom) :: nil | :item | :action | {:guard | :not_guard, integer}
  def type(key) do
    Decks.Base.type(key) ||
      Guild.type(key) ||
      Imperial.type(key) ||
      Necros.type(key) ||
      Wild.type(key)
  end

  @spec faction(atom) :: nil | :guild | :imperial | :necros | :wild
  def faction(key) do
    Guild.faction(key) ||
      Imperial.faction(key) ||
      Necros.faction(key) ||
      Wild.faction(key)
  end

  @spec is_champion(atom) :: boolean
  def is_champion(key) do
    case type(key) do
      {:guard, _} -> true
      {:not_guard, _} -> true
      _ -> false
    end
  end

  @spec is_guard(atom) :: boolean
  def is_guard(key) do
    case type(key) do
      {:guard, _} -> true
      _ -> false
    end
  end

  @spec primary_ability(Game.t(), atom, Player.id()) :: Game.t()
  def primary_ability(game, key, player_id) do
    # Guild.primary_ability(game, key, player_id) ||
    # Imperial.primary_ability(game, key, player_id) ||
    # Necros.primary_ability(game, key, player_id) ||
    # Wild.primary_ability(game, key, player_id) ||
    Decks.Base.primary_ability(game, key, player_id) ||
      game
  end

  @spec expend(Card.t()) :: Card.t()
  def expend(card), do: %{card | expend_ability_used: true}

  @spec prepare(Card.t()) :: Card.t()
  def prepare(card), do: %{card | expend_ability_used: false}
end
