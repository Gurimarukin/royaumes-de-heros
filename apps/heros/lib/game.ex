defmodule Heros.Game do
  use GenServer, restart: :temporary

  require Logger

  alias Heros.{Cards, Game, KeyListUtils, Player}
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

  def empty(players, current_player) do
    %Game{
      players: players,
      current_player: current_player,
      gems: [],
      market: [],
      market_deck: [],
      cemetery: []
    }
  end

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
          :ok | atom
  def play_card(game, player_id, card_id) do
    GenServer.call(game, {:play_card, player_id, card_id})
  end

  @spec buy_card(atom | pid | {atom, any} | {:via, atom, any}, Player.id(), Card.id()) ::
          :ok | atom
  def buy_card(game, player_id, card_id) do
    GenServer.call(game, {:buy_card, player_id, card_id})
  end

  @spec attack(
          atom | pid | {atom, any} | {:via, atom, any},
          Player.id(),
          Player.id(),
          :player | Card.id()
        ) :: :ok | atom
  def attack(game, attacker, defender, what) do
    GenServer.call(game, {:attack, attacker, defender, what})
  end

  @spec discard_phase(atom | pid | {atom, any} | {:via, atom, any}, Player.id()) :: :ok | atom
  def discard_phase(game, player_id) do
    GenServer.call(game, {:discard_phase, player_id})
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

      {:reply, status, update_in(game.players, &KeyListUtils.replace(&1, player_id, new_player))}
    end)
  end

  def handle_call({:buy_card, player_id, card_id}, _from, game) do
    if_is_current_player(game, player_id, fn player ->
      case KeyListUtils.find(game.market, card_id) do
        nil ->
          case KeyListUtils.find(game.gems, card_id) do
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
      case KeyListUtils.find(game.players, defender_id) do
        nil ->
          {:reply, :not_found, game}

        defender ->
          if attacker.combat > 0 and is_next_to_current_player(game, defender_id) do
            attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, what)
          else
            {:reply, :forbidden, game}
          end
      end
    end)
  end

  def handle_call({:discard_phase, player_id}, _from, game) do
    if_is_current_player(game, player_id, fn _player ->
      new_game = %{
        game
        | players: KeyListUtils.update(game.players, player_id, &Player.discard_phase/1),
          current_player: next_player_alive(game)
      }

      {:reply, :ok, new_game}
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
      case KeyListUtils.find(game.players, player_id) do
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
          |> update_in([:players], &KeyListUtils.replace(&1, player_id, new_player))
          |> update_in([:market], &KeyListUtils.replace_with_key(&1, card_id, new_market_card))
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
          |> update_in([:players], &KeyListUtils.replace(&1, player_id, new_player))
          |> update_in([:gems], &KeyListUtils.delete(&1, card_id))

        {:reply, :ok, new_game}

      {status, _} ->
        {:reply, status, game}
    end
  end

  defp next_player_alive(game) do
    case Enum.find_index(game.players, fn {id, _} -> id == game.current_player end) do
      nil -> nil
      i -> next_player_alive_rec(game.players, i)
    end
  end

  defp previous_player_alive(game) do
    case Enum.find_index(game.players, fn {id, _} -> id == game.current_player end) do
      nil -> nil
      i -> previous_player_alive_rec(game.players, i)
    end
  end

  defp next_player_alive_rec(players, i) do
    i = if i == length(players) - 1, do: 0, else: i + 1
    step_if_dead(players, i, &next_player_alive_rec/2)
  end

  defp previous_player_alive_rec(players, i) do
    i = if i == 0, do: length(players) - 1, else: i - 1
    step_if_dead(players, i, &previous_player_alive_rec/2)
  end

  defp step_if_dead(players, i, f) do
    case Enum.fetch(players, i) do
      {:ok, {k, p}} -> if Player.is_alive(p), do: k, else: f.(players, i)
      :error -> nil
    end
  end

  defp is_next_to_current_player(game, player_id) do
    case next_player_alive(game) do
      nil ->
        false

      ^player_id ->
        true

      _ ->
        case previous_player_alive(game) do
          nil -> false
          ^player_id -> true
          _ -> false
        end
    end
  end

  # attack
  defp attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, :player) do
    attack_player(game, {attacker_id, attacker}, {defender_id, defender})
  end

  defp attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, card_id) do
    case KeyListUtils.find(defender.fight_zone, card_id) do
      nil -> {:reply, :not_found, game}
      card -> attack_card(game, {attacker_id, attacker}, {defender_id, defender}, {card_id, card})
    end
  end

  defp attack_player(game, {attacker_id, attacker}, {defender_id, defender}) do
    defender_has_guard = Enum.any?(defender.fight_zone, fn {_, c} -> Card.is_guard(c.key) end)

    if defender_has_guard or not Player.is_alive(defender) do
      {:reply, :forbidden, game}
    else
      damages = min(attacker.combat, defender.hp)
      new_attacker = update_in(attacker.combat, &(&1 - damages))
      new_defender = update_in(defender.hp, &(&1 - damages))

      new_game =
        update_in(game.players, fn players ->
          players
          |> KeyListUtils.replace(attacker_id, new_attacker)
          |> KeyListUtils.replace(defender_id, new_defender)
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
    if attacker.combat >= defense do
      new_attacker = update_in(attacker.combat, &(&1 - defense))

      new_defender =
        defender
        |> update_in([:discard], &([{card_id, card}] ++ &1))
        |> update_in([:fight_zone], &KeyListUtils.delete(&1, card_id))

      new_game =
        update_in(game.players, fn players ->
          players
          |> KeyListUtils.replace(attacker_id, new_attacker)
          |> KeyListUtils.replace(defender_id, new_defender)
        end)

      {:reply, :ok, new_game}
    else
      {:reply, :forbidden, game}
    end
  end
end
