defmodule Heros.Game.Stage do
  @callback projection_for_session(session_id :: String.t(), game :: term) :: term

  @callback handle_call(request :: term, from :: GenServer.from(), game :: term) ::
              {:reply, reply, new_game}
              | {:noreply, new_game}
              | {:stop, reason, reply, new_game}
              | {:stop, reason, new_game}
            when reply: term, new_game: term, reason: term

  @callback handle_update(update :: term, from :: GenServer.from(), game :: term) ::
              {:reply, reply, new_game}
              | {:noreply, new_game}
              | {:stop, reason, reply, new_game}
              | {:stop, reason, new_game}
            when reply: term, new_game: term, reason: term

  @callback on_update(new_game :: term) :: term
end
