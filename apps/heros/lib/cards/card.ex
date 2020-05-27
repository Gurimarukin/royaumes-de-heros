defmodule Heros.Cards.Card do
  alias Heros.Game
  alias Heros.Cards.{Card, Decks, Guild, Imperial, Necros, Wild}

  @type id :: binary

  @type t :: %__MODULE__{
          key: atom,
          expend_ability_used: boolean,
          ally_ability_used: boolean
        }
  @enforce_keys [:key, :expend_ability_used, :ally_ability_used]
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

  @spec primary_ability(Game.t(), atom, Player.id()) :: Game.t()
  def primary_ability(game, :gem, player_id) do
    game |> Game.add_gold(player_id, 2)
  end

  def primary_ability(game, key, player_id) do
    Decks.Base.primary_ability(game, key, player_id) ||
      Guild.primary_ability(game, key, player_id) ||
      Imperial.primary_ability(game, key, player_id) ||
      Necros.primary_ability(game, key, player_id) ||
      Wild.primary_ability(game, key, player_id) ||
      game
  end

  @spec expend_ability(Game.t(), atom, Player.id(), Card.id()) :: nil | Game.t()
  def expend_ability(game, key, player_id, card_id) do
    Guild.expend_ability(game, key, player_id, card_id) ||
      Imperial.expend_ability(game, key, player_id, card_id) ||
      Necros.expend_ability(game, key, player_id, card_id) ||
      Wild.expend_ability(game, key, player_id, card_id)
  end

  @spec ally_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def ally_ability(game, key, player_id) do
    Guild.ally_ability(game, key, player_id) ||
      Imperial.ally_ability(game, key, player_id) ||
      Necros.ally_ability(game, key, player_id) ||
      Wild.ally_ability(game, key, player_id)
  end

  @spec sacrifice_ability(Game.t(), atom, Player.id()) :: nil | Game.t()
  def sacrifice_ability(game, :gem, player_id) do
    game |> Game.add_combat(player_id, 3)
  end

  def sacrifice_ability(game, key, player_id) do
    Guild.ally_ability(game, key, player_id) ||
      Imperial.sacrifice_ability(game, key, player_id) ||
      Necros.ally_ability(game, key, player_id) ||
      Wild.ally_ability(game, key, player_id)
  end

  def expend(card), do: %{card | expend_ability_used: true}

  def prepare(card), do: %{card | expend_ability_used: false}

  def consume_ally_ability(card), do: %{card | ally_ability_used: true}
end
