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
          Game.update()
  def play_card(game, player_id, card_id) do
    GenServer.call(game, {:play_card, player_id, card_id})
  end

  @spec use_expend_ability(atom | pid | {atom, any} | {:via, atom, any}, Player.id(), Card.id()) ::
          Game.update()
  def use_expend_ability(game, player_id, card_id) do
    GenServer.call(game, {:use_expend_ability, player_id, card_id})
  end

  @spec use_ally_ability(atom | pid | {atom, any} | {:via, atom, any}, Player.id(), Card.id()) ::
          Game.update()
  def use_ally_ability(game, player_id, card_id) do
    GenServer.call(game, {:use_ally_ability, player_id, card_id})
  end

  @spec buy_card(atom | pid | {atom, any} | {:via, atom, any}, Player.id(), Card.id()) ::
          Game.update()
  def buy_card(game, player_id, card_id) do
    GenServer.call(game, {:buy_card, player_id, card_id})
  end

  @spec attack(
          atom | pid | {atom, any} | {:via, atom, any},
          Player.id(),
          Player.id(),
          :player | Card.id()
        ) :: Game.update()
  def attack(game, attacker_id, defender_id, what) do
    GenServer.call(game, {:attack, attacker_id, defender_id, what})
  end

  @spec buy_card(atom | pid | {atom, any} | {:via, atom, any}, Player.id(), {atom, any}) ::
          Game.update()
  def perform_interaction(game, player_id, interaction) do
    GenServer.call(game, {:perform_interaction, player_id, interaction})
  end

  @spec discard_phase(atom | pid | {atom, any} | {:via, atom, any}, Player.id()) :: Game.update()
  def discard_phase(game, player_id) do
    GenServer.call(game, {:discard_phase, player_id})
  end

  @spec draw_phase(atom | pid | {atom, any} | {:via, atom, any}, Player.id()) :: Game.update()
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
    # TODO: main_phase_action
    current_player_action(game, player_id, fn player ->
      Game.play_card(game, {player_id, player}, card_id)
    end)
  end

  def handle_call({:use_expend_ability, player_id, card_id}, _from, game) do
    # TODO: main_phase_action
    current_player_action(game, player_id, fn player ->
      Game.use_expend_ability(game, {player_id, player}, card_id)
    end)
  end

  def handle_call({:use_ally_ability, player_id, card_id}, _from, game) do
    # TODO: main_phase_action
    current_player_action(game, player_id, fn player ->
      Game.use_ally_ability(game, {player_id, player}, card_id)
    end)
  end

  def handle_call({:buy_card, player_id, card_id}, _from, game) do
    # TODO: main_phase_action
    current_player_action(game, player_id, fn player ->
      Game.buy_card(game, {player_id, player}, card_id)
    end)
  end

  def handle_call({:attack, attacker_id, defender_id, what}, _from, game) do
    # TODO: main_phase_action
    current_player_action(game, attacker_id, fn attacker ->
      Game.attack(game, {attacker_id, attacker}, defender_id, what)
    end)
  end

  def handle_call({:perform_interaction, player_id, interaction}, _from, game) do
    current_player_action(game, player_id, fn player ->
      Game.perform_interaction(game, {player_id, player}, interaction)
    end)
  end

  def handle_call({:discard_phase, player_id}, _from, game) do
    # TODO: check not already done
    current_player_action(game, player_id, fn _player ->
      Game.discard_phase(game, player_id)
    end)
  end

  def handle_call({:draw_phase, player_id}, _from, game) do
    current_player_action(game, player_id, fn _player ->
      Game.draw_phase(game, player_id)
    end)
  end

  #
  # Helpers
  #

  defp error(game), do: {:reply, :error, game}

  defp ok(game), do: {:reply, {:ok, game}, game}

  @spec to_reply(Game.update(), Game.t()) :: {:reply, Game.update(), Game.t()}
  defp to_reply({:ok, game}, _), do: ok(game)
  defp to_reply({:victory, winner, game}, _), do: {:reply, {:victory, winner, game}, game}
  defp to_reply(:error, game), do: {:reply, :error, game}

  # defp main_phase_action(game, player_id, f) do
  #   current_player_action(game, player_id, fn player ->
  #     case player.pending_interactions do
  #       [] -> f.(player)
  #       _ -> error(game)
  #     end
  #   end)
  # end

  defp current_player_action(game, player_id, f) do
    if game.current_player == player_id do
      case KeyListUtils.find(game.players, player_id) do
        nil -> error(game)
        player -> to_reply(f.(player), game)
      end
    else
      error(game)
    end
  end
end
