defmodule Heros.Game do
  use GenServer, restart: :temporary

  require Logger

  alias Heros.{Card, Cards, Game, Player, Utils}

  @type t :: %{
          players: list({Player.id(), Player.t()}),
          current_player: Player.id(),
          gems: list(Card.t()),
          market: list(nil | Card.t()),
          market_deck: list(Card.t()),
          cemetery: list(Card.t())
        }
  @enforce_keys [:players, :current_player, :gems, :market, :market_deck, :cemetery]
  defstruct [:players, :current_player, :gems, :market, :market_deck, :cemetery]

  @behaviour Access

  @impl Access
  def fetch(game, key), do: Map.fetch(game, key)

  @impl Access
  def get_and_update(game, key, fun), do: Map.get_and_update(game, key, fun)

  @impl Access
  def pop(game, key, default \\ nil), do: Map.pop(game, key, default)

  # Client
  @spec start({:from_player_ids, list(Player.id())} | {:from_game, Game.t()}) ::
          :ignore | {:error, any} | {:ok, pid}
  def start(construct) do
    GenServer.start_link(__MODULE__, construct)
  end

  @spec get(atom | pid | {atom, any} | {:via, atom, any}) :: Game.t()
  def get(game) do
    GenServer.call(game, :get)
  end

  def play_card(game, player_id, card_id) do
    GenServer.call(game, {:play_card, player_id, card_id})
  end

  def buy_card(game, player_id, card_id) do
    GenServer.call(game, {:buy_card, player_id, card_id})
  end

  # Server
  @impl true
  @spec init(
          {:from_player_ids, list(Player.t())}
          | {:from_game, Game.t()}
        ) ::
          {:ok, Game.t()}
          | {:stop, :invalid_players | :invalid_players_number}
  def init({:from_player_ids, players}) do
    case check_init_players(players) do
      :ok -> {:ok, start_game(players)}
      {:error, error} -> {:stop, error}
    end
  end

  def init({:from_game, game}) do
    {:ok, game}
  end

  @impl true
  def handle_call(:get, _from, game) do
    {:reply, game, game}
  end

  def handle_call({:play_card, player_id, card_id}, _from, game) do
    if_is_current_player(game, player_id, fn player ->
      {status, new_player} = Player.play_card(player, card_id)
      {:reply, status, update_in(game.players, &Utils.keyreplace(&1, player_id, new_player))}
    end)
  end

  def handle_call({:buy_card, player_id, card_id}, _from, game) do
    if_is_current_player(game, player_id, fn player ->
      case Utils.keyfind(game.market, card_id) do
        nil ->
          case Utils.keyfind(game.gems, card_id) do
            nil -> {:reply, :not_found, game}
            card -> buy_gem(game, {player_id, player}, {card_id, card})
          end

        card ->
          buy_market_card(game, {player_id, player}, {card_id, card})
      end
    end)
  end

  # Helpers
  @spec check_init_players(list(Player.t())) ::
          :ok | {:error, :invalid_players | :invalid_players_number}
  defp check_init_players(players) do
    if is_list(players) do
      n = length(players)

      if 2 <= n && n <= 4 do
        :ok
      else
        {:error, :invalid_players_number}
      end
    else
      {:error, :invalid_players}
    end
  end

  defp start_game(players) do
    {market, market_deck} = init_market()

    %Game{
      players: init_players(players),
      current_player: hd(players),
      gems: Cards.gems(),
      market: market,
      market_deck: market_deck,
      cemetery: []
    }
  end

  defp init_players(players) do
    n_players = length(players)

    players
    |> Enum.with_index()
    |> Enum.map(fn {player_id, i} ->
      {player_id,
       Player.init(
         cond do
           # first player always gets 3 cards
           i == 0 -> 3
           # when 2 players, second player gets 5 cards
           i == 1 && n_players == 2 -> 5
           # else, second player gets 4 cards
           i == 1 -> 4
           # other players get 5 cards
           true -> 5
         end
       )}
    end)
  end

  defp init_market do
    Cards.market()
    |> Enum.shuffle()
    |> Enum.split(5)
  end

  defp if_is_current_player(game, player_id, f) do
    if game.current_player == player_id do
      case Utils.keyfind(game.players, player_id) do
        nil -> {:reply, :not_found, game}
        player -> f.(player)
      end
    else
      {:reply, :forbidden, game}
    end
  end

  defp buy_market_card(game, {player_id, player}, {card_id, card}) do
    case Player.buy_card(player, {card_id, card}) do
      {:ok, new_player} ->
        {new_market_card, new_market_deck} =
          case game.market_deck do
            [] -> {nil, []}
            [new_market_card | new_market_deck] -> {new_market_card, new_market_deck}
          end

        new_game =
          game
          |> update_in([:players], &Utils.keyreplace(&1, player_id, new_player))
          |> update_in([:market], &Utils.keyfullereplace(&1, card_id, new_market_card))
          |> put_in([:market_deck], new_market_deck)

        {:reply, :ok, new_game}

      {status, _} ->
        {:reply, status, game}
    end
  end

  defp buy_gem(game, {player_id, player}, {card_id, card}) do
    case Player.buy_card(player, {card_id, card}) do
      {:ok, new_player} ->
        new_game =
          game
          |> update_in([:players], &Utils.keyreplace(&1, player_id, new_player))
          |> update_in([:gems], &Utils.keydelete(&1, card_id))

        {:reply, :ok, new_game}

      {status, _} ->
        {:reply, status, game}
    end
  end
end
