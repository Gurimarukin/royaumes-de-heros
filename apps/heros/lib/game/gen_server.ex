defmodule Heros.Game.GenServer do
  use GenServer, restart: :temporary

  require Logger

  alias Heros.{Cards, Game, KeyListUtils, Player}
  alias Heros.Cards.Card

  @type option_game :: {:ok, Game.t()} | :error

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
          option_game()
  def play_card(game, player_id, card_id) do
    GenServer.call(game, {:play_card, player_id, card_id})
  end

  @spec use_expend_ability(atom | pid | {atom, any} | {:via, atom, any}, Player.id(), Card.id()) ::
          option_game()
  def use_expend_ability(game, player_id, card_id) do
    GenServer.call(game, {:use_expend_ability, player_id, card_id})
  end

  @spec use_ally_ability(atom | pid | {atom, any} | {:via, atom, any}, Player.id(), Card.id()) ::
          option_game()
  def use_ally_ability(game, player_id, card_id) do
    GenServer.call(game, {:use_ally_ability, player_id, card_id})
  end

  @spec buy_card(atom | pid | {atom, any} | {:via, atom, any}, Player.id(), Card.id()) ::
          option_game()
  def buy_card(game, player_id, card_id) do
    GenServer.call(game, {:buy_card, player_id, card_id})
  end

  @spec attack(
          atom | pid | {atom, any} | {:via, atom, any},
          Player.id(),
          Player.id(),
          :player | Card.id()
        ) :: option_game() | {:victory, Player.id(), Game.t()}
  def attack(game, attacker, defender, what) do
    GenServer.call(game, {:attack, attacker, defender, what})
  end

  @spec buy_card(atom | pid | {atom, any} | {:via, atom, any}, Player.id(), {atom, any}) ::
          option_game()
  def perform_interaction(game, player_id, interaction) do
    GenServer.call(game, {:perform_interaction, player_id, interaction})
  end

  @spec discard_phase(atom | pid | {atom, any} | {:via, atom, any}, Player.id()) :: option_game()
  def discard_phase(game, player_id) do
    GenServer.call(game, {:discard_phase, player_id})
  end

  @spec draw_phase(atom | pid | {atom, any} | {:via, atom, any}, Player.id()) :: option_game()
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
      case KeyListUtils.find(player.hand, card_id) do
        nil ->
          error(game)

        card ->
          game
          |> Game.play_card({player_id, player}, {card_id, card})
          |> ok()
      end
    end)
  end

  def handle_call({:use_expend_ability, player_id, card_id}, _from, game) do
    # TODO: main_phase_action
    current_player_action(game, player_id, fn player ->
      case KeyListUtils.find(player.fight_zone, card_id) do
        nil ->
          error(game)

        card ->
          if card.expend_ability_used do
            error(game)
          else
            game
            |> Game.use_expend_ability({player_id, player}, {card_id, card})
            |> ok_or_error(game)
          end
      end
    end)
  end

  def handle_call({:use_ally_ability, player_id, card_id}, _from, game) do
    # TODO: main_phase_action
    current_player_action(game, player_id, fn player ->
      case KeyListUtils.find(player.fight_zone, card_id) do
        nil ->
          error(game)

        card ->
          case Card.faction(card.key) do
            nil ->
              error(game)

            faction ->
              if card.ally_ability_used or count_from_faction(player.fight_zone, faction) < 2 do
                error(game)
              else
                game
                |> Game.use_ally_ability({player_id, player}, {card_id, card})
                |> ok_or_error(game)
              end
          end
      end
    end)
  end

  def handle_call({:buy_card, player_id, card_id}, _from, game) do
    # TODO: main_phase_action
    current_player_action(game, player_id, fn player ->
      case KeyListUtils.find(game.market, card_id) do
        nil ->
          case KeyListUtils.find(game.gems, card_id) do
            nil ->
              error(game)

            card ->
              game
              |> Game.buy_gem({player_id, player}, {card_id, card})
              |> ok_or_error(game)
          end

        card ->
          game
          |> Game.buy_market_card({player_id, player}, {card_id, card})
          |> ok_or_error(game)
      end
    end)
  end

  def handle_call({:attack, attacker_id, defender_id, what}, _from, game) do
    # TODO: main_phase_action
    current_player_action(game, attacker_id, fn attacker ->
      case KeyListUtils.find(game.players, defender_id) do
        nil ->
          error(game)

        defender ->
          if attacker.combat > 0 and Game.is_next_to_current_player(game, defender_id) do
            attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, what)
          else
            error(game)
          end
      end
    end)
  end

  def handle_call({:perform_interaction, player_id, interaction}, _from, game) do
    current_player_action(game, player_id, fn player ->
      {name, _} = interaction

      case player.pending_interactions do
        [] ->
          error(game)

        [{^name, value} | tail] ->
          game
          |> Game.replace_player(player_id, %{player | pending_interactions: tail})
          |> Game.perform_interaction(player_id, {name, value}, interaction)
          |> ok_or_error(game)

        _ ->
          error(game)
      end
    end)
  end

  def handle_call({:discard_phase, player_id}, _from, game) do
    # TODO: check not already done
    current_player_action(game, player_id, fn _player ->
      game
      |> Game.discard_phase(player_id)
      |> ok()
    end)
  end

  def handle_call({:draw_phase, player_id}, _from, game) do
    # TODO: check discard_phase done
    current_player_action(game, player_id, fn _player ->
      game
      |> Game.draw_phase(player_id)
      |> ok()
    end)
  end

  #
  # Helpers
  #

  defp error(game), do: {:reply, :error, game}

  defp ok(game), do: {:reply, {:ok, game}, game}

  defp victory(game, attacker_id), do: {:reply, {:victory, attacker_id, game}, game}

  @spec ok_or_error({:ok, Game.t()} | :error, Game.t()) ::
          {:reply, option_game(), Game.t()}
  defp ok_or_error({:ok, game}, _), do: ok(game)
  defp ok_or_error(:error, game), do: {:reply, :error, game}

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
        player -> f.(player)
      end
    else
      error(game)
    end
  end

  defp attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, :player) do
    game
    |> Game.attack_player({attacker_id, attacker}, {defender_id, defender})
    |> check_victory(game, attacker_id)
  end

  defp attack_bis(game, {attacker_id, attacker}, {defender_id, defender}, card_id) do
    case KeyListUtils.find(defender.fight_zone, card_id) do
      nil ->
        error(game)

      card ->
        game
        |> Game.attack_card({attacker_id, attacker}, {defender_id, defender}, {card_id, card})
        |> ok_or_error(game)
    end
  end

  defp check_victory({:ok, game}, _, attacker_id) do
    players_alive = game.players |> Enum.count(fn {_, p} -> Player.is_alive(p) end)

    if players_alive == 1 do
      victory(game, attacker_id)
    else
      ok(game)
    end
  end

  defp check_victory(:error, game, _), do: error(game)

  @spec count_from_faction(list({Card.id(), Card.t()}), atom) :: integer
  defp count_from_faction(cards, faction) do
    Enum.count(cards, fn {_, c} -> Card.faction(c.key) == faction end)
  end
end
