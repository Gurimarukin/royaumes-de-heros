defmodule Heros.Game.Match do
  use Heros.Game.Stage

  def handle_call(_request, _from, _game),
    do: raise(MatchError, message: "no match of handle_call/3")

  def projection_for_session(_session_id, _game) do
    %{}
  end

  def handle_update(_update, _from, _game),
    do: raise(MatchError, message: "no match of handle_update/3")

  def on_update(game) do
    game
  end
end
