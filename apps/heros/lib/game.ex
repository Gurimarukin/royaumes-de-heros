defmodule Heros.Game do
  use GenServer, restart: :temporary

  require Logger

  alias Heros.{Cards, Game, Player, Utils}
  alias Heros.Cards.Card

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

  #
  # Client
  #
  @spec start({:from_player_ids, list(Player.id())} | {:from_game, Game.t()}) ::
          :ignore | {:error, any} | {:ok, pid}
  def start(construct) do
    GenServer.start_link(__MODULE__, construct)
  end

  @spec get(atom | pid | {atom, any} | {:via, atom, any}) :: Game.t()
  def get(game) do
    GenServer.call(game, :get)
  end

  @spec play_card(atom | pid | {atom, any} | {:via, atom, any}, Player.id(), Card.id()) ::
          :ok | any
  def play_card(game, player_id, card_id) do
    GenServer.call(game, {:play_card, player_id, card_id})
  end

  @spec buy_card(atom | pid | {atom, any} | {:via, atom, any}, Player.id(), Card.id()) ::
          :ok | any
  def buy_card(game, player_id, card_id) do
    GenServer.call(game, {:buy_card, player_id, card_id})
  end

  @spec attack(
          atom | pid | {atom, any} | {:via, atom, any},
          Player.id(),
          Player.id(),
          :player | Card.id()
        ) :: :ok | any
  def attack(game, attacker, defender, what) do
    GenServer.call(game, {:attack, attacker, defender, what})
  end

  #
  # Server
  #
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

  def handle_call({:attack, attacker_id, defender_id, what}, _from, game) do
    if_is_current_player(game, attacker_id, fn attacker ->
      if attacker.attack > 0 and player_can_attack(game, attacker_id, defender_id) do
        case Utils.keyfind(game.players, defender_id) do
          nil -> {:reply, :not_found, game}
          defender -> attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, what)
        end
      else
        {:reply, :forbidden, game}
      end
    end)
  end

  #
  # Helpers
  #
  # init
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

  # buy
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

  # attack
  defp player_can_attack(game, attacker_id, defender_id) do
    case {
      Enum.find_index(game.players, fn {id, _} -> id == attacker_id end),
      Enum.find_index(game.players, fn {id, _} -> id == defender_id end)
    } do
      {nil, _} -> true
      {_, nil} -> true
      {0, j} -> j == 1 or j == length(game.players) - 1
      {i, 0} -> i == 1 or i == length(game.players) - 1
      {i, j} -> abs(i - j) == 1
    end
  end

  defp attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, :player) do
    attack_player(game, {attacker_id, attacker}, {defender_id, defender})
  end

  defp attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, card_id) do
    case Utils.keyfind(defender.fight_zone, card_id) do
      nil -> {:reply, :not_found, game}
      card -> attack_card(game, {attacker_id, attacker}, {defender_id, defender}, {card_id, card})
    end
  end

  defp attack_player(game, {attacker_id, attacker}, {defender_id, defender}) do
    defender_has_guard = Enum.any?(defender.fight_zone, fn {_, c} -> Card.is_guard(c.key) end)

    if defender_has_guard or not Player.is_alive(defender) do
      {:reply, :forbidden, game}
    else
      damages = min(attacker.attack, defender.hp)
      new_attacker = update_in(attacker.attack, &(&1 - damages))
      new_defender = update_in(defender.hp, &(&1 - damages))

      new_game =
        update_in(game.players, fn players ->
          players
          |> Utils.keyreplace(attacker_id, new_attacker)
          |> Utils.keyreplace(defender_id, new_defender)
        end)

      {:reply, :ok, new_game}
    end
  end

  defp attack_card(game, {attacker_id, attacker}, {defender_id, defender}, {card_id, card}) do
    case Card.champion(card.key) do
      {:guard, defense} ->
        attack_card_bis(
          game,
          {attacker_id, attacker},
          {defender_id, defender},
          {card_id, card},
          defense
        )

      {:not_guard, defense} ->
        defender_has_guard = Enum.any?(defender.fight_zone, fn {_, c} -> Card.is_guard(c.key) end)

        if defender_has_guard do
          {:reply, :forbidden, game}
        else
          attack_card_bis(
            game,
            {attacker_id, attacker},
            {defender_id, defender},
            {card_id, card},
            defense
          )
        end

      nil ->
        {:reply, :forbidden, game}
    end
  end

  defp attack_card_bis(
         game,
         {attacker_id, attacker},
         {defender_id, defender},
         {card_id, card},
         defense
       ) do
    if attacker.attack >= defense do
      new_attacker = update_in(attacker.attack, &(&1 - defense))

      new_defender =
        defender
        |> update_in([:discard], &([{card_id, card}] ++ &1))
        |> update_in([:fight_zone], &Utils.keydelete(&1, card_id))

      new_game =
        update_in(game.players, fn players ->
          players
          |> Utils.keyreplace(attacker_id, new_attacker)
          |> Utils.keyreplace(defender_id, new_defender)
        end)

      {:reply, :ok, new_game}
    else
      {:reply, :forbidden, game}
    end
  end
end
