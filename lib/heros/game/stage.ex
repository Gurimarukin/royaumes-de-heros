defmodule Heros.Game.Stage do
  @callback projection_for_session(session_id :: String.t(), game :: term) :: term

  @callback handle_call(request :: term, from :: GenServer.from(), game :: term) ::
              {:reply, reply, new_state}
              | {:noreply, new_state}
              | {:stop, reason, reply, new_state}
              | {:stop, reason, new_state}
            when reply: term, new_state: term, reason: term

  @callback handle_update(update :: term, from :: GenServer.from(), game :: term) ::
              {:reply, reply, new_state}
              | {:noreply, new_state}
              | {:stop, reason, reply, new_state}
              | {:stop, reason, new_state}
            when reply: term, new_state: term, reason: term

  @callback on_update(new_game :: term) :: term
end
