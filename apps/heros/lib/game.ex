defmodule Heros.Game do
  use GenServer, restart: :temporary

  require Logger

  alias Heros.{Card, Cards, Game, Player}

  @type t :: %{
          players: list({Player.id(), Player.t()}),
          current_player: Player.id(),
          gems: list(Card.t()),
          market: list(Card.t()),
          market_deck: list(Card.t()),
          cemetery: list(Card.t())
        }
  @enforce_keys [:players, :current_player, :gems, :market, :market_deck, :cemetery]
  defstruct [:players, :current_player, :gems, :market, :market_deck, :cemetery]

  # Client
  @spec start(list(Player.id())) :: :ignore | {:error, any} | {:ok, pid}
  def start(players) do
    GenServer.start_link(__MODULE__, players)
  end

  @spec get(atom | pid | {atom, any} | {:via, atom, any}) :: Game.t()
  def get(game) do
    GenServer.call(game, :get)
  end

  # Server
  @impl true
  @spec init(any) :: {:ok, Game.t()} | {:stop, :invalid_players | :invalid_players_number}
  def init(players) do
    case check_players(players) do
      :ok -> {:ok, start_game(players)}
      {:error, error} -> {:stop, error}
    end
  end

  @impl true
  def handle_call(:get, _from, game) do
    {:reply, game, game}
  end

  # Helpers
  @spec check_players(list(Player.t())) ::
          :ok | {:error, :invalid_players | :invalid_players_number}
  defp check_players(players) do
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
end
