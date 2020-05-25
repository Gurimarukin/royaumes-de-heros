defmodule Heros.Game.GenServer do
  use GenServer, restart: :temporary

  require Logger

  alias Heros.{Cards, Game, KeyListUtils, Player}
  alias Heros.Cards.Card

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
        ) :: :ok | {:victory, Player.id()} | atom
  def attack(game, attacker, defender, what) do
    GenServer.call(game, {:attack, attacker, defender, what})
  end

  @spec discard_phase(atom | pid | {atom, any} | {:via, atom, any}, Player.id()) :: :ok | atom
  def discard_phase(game, player_id) do
    GenServer.call(game, {:discard_phase, player_id})
  end

  @spec draw_phase(atom | pid | {atom, any} | {:via, atom, any}, Player.id()) :: :ok | atom
  def draw_phase(game, player_id) do
    GenServer.call(game, {:draw_phase, player_id})
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
          | {:stop, :invalid_players}
  def init({:from_player_ids, player_ids}) do
    case Game.init_from_players(player_ids) do
      {:ok, game} -> {:ok, game}
      :error -> {:stop, :invalid_players}
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
      case KeyListUtils.find(player.hand, card_id) do
        nil ->
          {:reply, :not_found, game}

        card ->
          game = game |> Game.play_card({player_id, player}, {card_id, card})
          {:reply, :ok, game}
      end
    end)
  end

  def handle_call({:buy_card, player_id, card_id}, _from, game) do
    if_is_current_player(game, player_id, fn player ->
      case KeyListUtils.find(game.market, card_id) do
        nil ->
          case KeyListUtils.find(game.gems, card_id) do
            nil ->
              {:reply, :not_found, game}

            card ->
              game
              |> Game.buy_gem({player_id, player}, {card_id, card})
              |> ok_or_forbidden(game)
          end

        card ->
          game
          |> Game.buy_market_card({player_id, player}, {card_id, card})
          |> ok_or_forbidden(game)
      end
    end)
  end

  def handle_call({:attack, attacker_id, defender_id, what}, _from, game) do
    if_is_current_player(game, attacker_id, fn attacker ->
      case KeyListUtils.find(game.players, defender_id) do
        nil ->
          {:reply, :not_found, game}

        defender ->
          if attacker.combat > 0 and Game.is_next_to_current_player(game, defender_id) do
            attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, what)
          else
            {:reply, :forbidden, game}
          end
      end
    end)
  end

  def handle_call({:discard_phase, player_id}, _from, game) do
    if_is_current_player(game, player_id, fn _player ->
      {:reply, :ok, game |> Game.discard_phase(player_id)}
    end)
  end

  def handle_call({:draw_phase, player_id}, _from, game) do
    if_is_current_player(game, player_id, fn _player ->
      {:reply, :ok, game |> Game.draw_phase(player_id)}
    end)
  end

  #
  # Helpers
  #

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

  @spec ok_or_forbidden({:ok, Game.t()} | :error, Game.t()) ::
          {:reply, :ok | :forbidden, Game.t()}
  defp ok_or_forbidden({:ok, game}, _), do: {:reply, :ok, game}
  defp ok_or_forbidden(:error, game), do: {:reply, :forbidden, game}

  defp attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, :player) do
    game
    |> Game.attack_player({attacker_id, attacker}, {defender_id, defender})
    |> check_victory(game, attacker_id)
  end

  defp attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, card_id) do
    case KeyListUtils.find(defender.fight_zone, card_id) do
      nil ->
        {:reply, :not_found, game}

      card ->
        game
        |> Game.attack_card({attacker_id, attacker}, {defender_id, defender}, {card_id, card})
        |> ok_or_forbidden(game)
    end
  end

  defp check_victory({:ok, game}, _, attacker_id) do
    players_alive = game.players |> Enum.count(fn {_, p} -> Player.is_alive(p) end)

    if players_alive == 1 do
      {:reply, {:victory, attacker_id}, game}
    else
      {:reply, :ok, game}
    end
  end

  defp check_victory(:error, game, _), do: {:reply, :forbidden, game}
end
