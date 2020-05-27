defmodule Heros.Game.GenServer do
  use GenServer, restart: :temporary

  require Logger

  alias Heros.{Game, Player}
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
  def interact(game, player_id, interaction) do
    GenServer.call(game, {:interact, player_id, interaction})
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
      :error -> {:stop, :error}
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
    Game.play_card(game, player_id, card_id)
    |> to_reply(game)
  end

  def handle_call({:use_expend_ability, player_id, card_id}, _from, game) do
    Game.use_expend_ability(game, player_id, card_id)
    |> to_reply(game)
  end

  def handle_call({:use_ally_ability, player_id, card_id}, _from, game) do
    Game.use_ally_ability(game, player_id, card_id)
    |> to_reply(game)
  end

  def handle_call({:buy_card, player_id, card_id}, _from, game) do
    Game.buy_card(game, player_id, card_id)
    |> to_reply(game)
  end

  def handle_call({:attack, attacker_id, defender_id, what}, _from, game) do
    Game.attack(game, attacker_id, defender_id, what)
    |> to_reply(game)
  end

  def handle_call({:interact, player_id, interaction}, _from, game) do
    Game.interact(game, player_id, interaction)
    |> to_reply(game)
  end

  def handle_call({:discard_phase, player_id}, _from, game) do
    Game.discard_phase(game, player_id)
    |> to_reply(game)
  end

  def handle_call({:draw_phase, player_id}, _from, game) do
    Game.draw_phase(game, player_id)
    |> to_reply(game)
  end

  @spec to_reply(Game.update(), Game.t()) :: {:reply, Game.update(), Game.t()}
  defp to_reply({:ok, game}, _), do: {:reply, {:ok, game}, game}
  defp to_reply({:victory, winner, game}, _), do: {:reply, {:victory, winner, game}, game}
  defp to_reply(:error, game), do: {:reply, :error, game}
end
