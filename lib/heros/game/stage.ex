defmodule Heros.Game.Stage do
  @callback projection_for_session(session_id :: String.t(), game :: Heros.Game) :: term

  @callback handle_call(request :: term, from :: GenServer.from(), game :: Heros.Game) ::
              {:reply, reply, new_state}
              | {:noreply, new_state}
              | {:stop, reason, reply, new_state}
              | {:stop, reason, new_state}
            when reply: term, new_state: term, reason: term

  @callback handle_update(update :: term, from :: GenServer.from(), game :: Heros.Game) ::
              {:reply, reply, new_state}
              | {:noreply, new_state}
              | {:stop, reason, reply, new_state}
              | {:stop, reason, new_state}
            when reply: term, new_state: term, reason: term

  @callback on_update(new_game :: Heros.Game) :: Heros.Game

  def __using__(_opts) do
  end
end
