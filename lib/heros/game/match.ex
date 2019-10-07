defmodule Heros.Game.Match do
  alias Heros.Game.{Match, Player}
  alias Heros.Cards

  defstruct players: [],
            current_player: nil

  def start_game(game) do
    put_in(game.match, %Match{})
    |> init_players()
    |> set_current_player()
    |> set_started()
  end

  defp init_players(game) do
    players =
      game.users
      |> Enum.map(fn {session_id, _session} ->
        {session_id, init_player()}
      end)

    put_in(game.match.players, players)
  end

  defp init_player do
    %Player{deck: Cards.Decks.Base.shuffled()}
  end

  defp set_current_player(game) do
    put_in(game.match.current_player, List.first(Map.keys(game.users)))
  end

  defp set_started(game), do: put_in(game.stage, :started)

  def handle_call(_request, _from, _game),
    do: raise(MatchError, message: "no match of handle_call/3")

  def projection_for_session(_session_id, game) do
    %{stage: game.stage}
  end

  def handle_update(_update, _from, _game),
    do: raise(MatchError, message: "no match of handle_update/3")

  def on_update(game) do
    game
  end
end
