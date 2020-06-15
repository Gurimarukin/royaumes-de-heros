defmodule Heros.Game.Cards.Card do
  alias Heros.Game
  alias Heros.Game.Cards.{Card, Decks, Guild, Imperial, Necros, Wild}

  @type id :: binary

  @type t :: %__MODULE__{
          key: atom,
          expend_ability_used: boolean,
          ally_ability_used: boolean
        }
  @enforce_keys [:key, :expend_ability_used, :ally_ability_used]
  @derive Jason.Encoder
  defstruct [:key, :expend_ability_used, :ally_ability_used]

  @spec get(atom) :: Heros.Cards.Card.t()
  def get(key) do
    %Card{
      key: key,
      expend_ability_used: false,
      ally_ability_used: false
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
  def type(:gem), do: :item

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

  @spec champion?(atom) :: boolean
  def champion?(key) do
    case type(key) do
      {:guard, _} -> true
      {:not_guard, _} -> true
      _ -> false
    end
  end

  @spec guard?(atom) :: boolean
  def guard?(key) do
    case type(key) do
      {:guard, _} -> true
      _ -> false
    end
  end

  @spec action?(atom) :: boolean
  def action?(key) do
    case type(key) do
      :action -> true
      _ -> false
    end
  end

  @spec primary_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def primary_ability(:gem) do
    fn game, player_id -> game |> Game.add_gold(player_id, 2) end
  end

  def primary_ability(key) do
    Decks.Base.primary_ability(key) ||
      Guild.primary_ability(key) ||
      Imperial.primary_ability(key) ||
      Necros.primary_ability(key) ||
      Wild.primary_ability(key)
  end

  @spec expend_ability(atom) :: nil | (Game.t(), Player.id(), Card.id() -> Game.t())
  def expend_ability(key) do
    Guild.expend_ability(key) ||
      Imperial.expend_ability(key) ||
      Necros.expend_ability(key) ||
      Wild.expend_ability(key)
  end

  @spec ally_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def ally_ability(key) do
    Guild.ally_ability(key) ||
      Imperial.ally_ability(key) ||
      Necros.ally_ability(key) ||
      Wild.ally_ability(key)
  end

  @spec sacrifice_ability(atom) :: nil | (Game.t(), Player.id() -> Game.t())
  def sacrifice_ability(:gem) do
    fn game, player_id -> game |> Game.add_combat(player_id, 3) end
  end

  def sacrifice_ability(key) do
    Guild.sacrifice_ability(key) ||
      Imperial.sacrifice_ability(key) ||
      Necros.sacrifice_ability(key) ||
      Wild.sacrifice_ability(key)
  end

  def data do
    [
      {nil, %{key: :gem}}
      | Decks.Base.get() ++ Guild.get() ++ Imperial.get() ++ Necros.get() ++ Wild.get()
    ]
    |> MapSet.new()
    |> Enum.reduce(%{}, fn {_id, %{key: key}}, acc ->
      Map.put(acc, key, %{
        cost: cost(key),
        type: type(key),
        faction: faction(key),
        expend: expend_ability(key) != nil,
        ally: ally_ability(key) != nil,
        sacrifice: sacrifice_ability(key) != nil
      })
    end)
  end

  def full_reset(card) do
    card
    |> prepare()
    |> reset_ally_ability()
  end

  def expend(card), do: %{card | expend_ability_used: true}

  def prepare(card), do: %{card | expend_ability_used: false}

  def consume_ally_ability(card), do: %{card | ally_ability_used: true}

  def reset_ally_ability(card), do: %{card | ally_ability_used: false}
end
