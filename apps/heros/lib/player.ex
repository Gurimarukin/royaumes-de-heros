defmodule Heros.Player do
  alias Heros.{Cards, KeyListUtils, Player}
  alias Heros.Cards.Card

  @type id :: String.t()

  @type t :: %{
          hp: integer,
          max_hp: integer,
          gold: integer,
          combat: integer,
          hand: list(Card.t()),
          deck: list(Card.t()),
          discard: list(Card.t()),
          fight_zone: list(Card.t())
          # inventory: list(Card.t())
          # enemy_fight_zone: list(Card.t())
        }
  @enforce_keys [:hp, :max_hp, :gold, :combat, :hand, :deck, :discard, :fight_zone]
  defstruct [:hp, :max_hp, :gold, :combat, :hand, :deck, :discard, :fight_zone]

  def empty do
    %Player{
      hp: 50,
      max_hp: 50,
      gold: 0,
      combat: 0,
      hand: [],
      deck: [],
      discard: [],
      fight_zone: []
    }
  end

  @spec init(non_neg_integer) :: Player.t()
  def init(n) do
    %{empty() | deck: Enum.shuffle(Cards.Decks.Base.get())}
    |> draw_cards(n)
  end

  @spec is_alive(Player.t()) :: boolean
  def is_alive(player), do: player.hp > 0

  @spec draw_cards(Player.t(), non_neg_integer) :: Player.t()
  def draw_cards(player, 0), do: player

  def draw_cards(player, n) do
    case {player.deck, player.discard} do
      {[], []} ->
        player

      {[], discard} ->
        %{
          player
          | deck: Enum.shuffle(discard),
            discard: []
        }

      {[head | tail], _} ->
        %{
          player
          | hand: player.hand ++ [head],
            deck: tail
        }
        |> draw_cards(n - 1)
    end
  end

  @spec play_card(Player.t(), Card.id()) :: {:ok, Player.t()} | :error
  def play_card(player, card_id) do
    case KeyListUtils.find(player.hand, card_id) do
      nil ->
        :error

      card ->
        {:ok,
         %{
           player
           | hand: player.hand |> KeyListUtils.delete(card_id),
             fight_zone: player.fight_zone ++ [{card_id, card}]
         }}
    end
  end

  @spec buy_card(Player.t(), {Card.id(), Card.t()}) :: {:ok, Player.t()} | :error
  def buy_card(player, card) do
    price = Card.price(elem(card, 1).key)

    if player.gold >= price do
      {:ok,
       %{player | discard: [card | player.discard]}
       |> decr_gold(price)}
    else
      :error
    end
  end

  @spec discard_phase(Player.t()) :: Player.t()
  def discard_phase(player) do
    {champions, non_champions} =
      player.fight_zone
      |> Enum.split_with(fn {_, c} -> Card.is_champion(c.key) end)

    %{
      player
      | gold: 0,
        combat: 0,
        hand: [],
        discard: Enum.reverse(player.hand) ++ Enum.reverse(non_champions) ++ player.discard,
        fight_zone: champions |> KeyListUtils.map(&Card.reset_state/1)
    }
  end

  def incr_hp(player, amount), do: %{player | hp: player.hp + amount}
  def decr_hp(player, amount), do: %{player | hp: player.hp - amount}

  def incr_gold(player, amount), do: %{player | gold: player.gold + amount}
  def decr_gold(player, amount), do: %{player | gold: player.gold - amount}

  def incr_combat(player, amount), do: %{player | combat: player.combat + amount}
  def decr_combat(player, amount), do: %{player | combat: player.combat - amount}
end
