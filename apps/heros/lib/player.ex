defmodule Heros.Player do
  alias Heros.{Cards, Player, Utils}
  alias Heros.Cards.Card

  @type id :: String.t()

  @type t :: %{
          hp: integer,
          max_hp: integer,
          gold: integer,
          attack: integer,
          hand: list(Card.t()),
          deck: list(Card.t()),
          discard: list(Card.t()),
          fight_zone: list(Card.t())
          # inventory: list(Card.t())
          # enemy_fight_zone: list(Card.t())
        }
  @enforce_keys [:hp, :max_hp, :gold, :attack, :hand, :deck, :discard, :fight_zone]
  defstruct [:hp, :max_hp, :gold, :attack, :hand, :deck, :discard, :fight_zone]

  @behaviour Access

  @impl Access
  def fetch(player, key), do: Map.fetch(player, key)

  @impl Access
  def get_and_update(player, key, fun), do: Map.get_and_update(player, key, fun)

  @impl Access
  def pop(player, key, default \\ nil), do: Map.pop(player, key, default)

  def empty do
    %Player{
      hp: 50,
      max_hp: 50,
      gold: 0,
      attack: 0,
      hand: [],
      deck: [],
      discard: [],
      fight_zone: []
    }
  end

  @spec init(integer) :: Player.t()
  def init(n) do
    empty()
    |> put_in([:deck], Enum.shuffle(Cards.Decks.Base.get()))
    |> draw_cards(n)
  end

  @spec draw_cards(Player.t(), integer) :: Player.t()
  def draw_cards(player, 0), do: player

  def draw_cards(player, n) do
    if length(player.deck) == 0 do
      if length(player.discard) == 0 do
        player
      else
        player
        |> put_in([:deck], Enum.shuffle(player.discard))
        |> put_in([:discard], [])
      end
    else
      [head | tail] = player.deck

      player
      |> update_in([:hand], &(&1 ++ [head]))
      |> put_in([:deck], tail)
      |> draw_cards(n - 1)
    end
  end

  @spec play_card(Player.t(), Card.id()) :: {atom, Player.t()}
  def play_card(player, card_id) do
    case Utils.keyfind(player.hand, card_id) do
      nil ->
        {:not_found, player}

      card ->
        {:ok,
         player
         |> update_in([:hand], &Utils.keydelete(&1, card_id))
         |> update_in([:fight_zone], &(&1 ++ [{card_id, card}]))}
    end
  end

  @spec buy_card(Player.t(), {Card.id(), Card.t()}) :: {atom, Player.t()}
  def buy_card(player, card) do
    price = Card.price(elem(card, 1).key)

    if player.gold >= price do
      {:ok,
       player
       |> update_in([:gold], &(&1 - price))
       |> update_in([:discard], &([card] ++ &1))}
    else
      {:forbidden, player}
    end
  end
end
