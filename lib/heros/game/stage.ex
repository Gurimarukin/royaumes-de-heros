defmodule Heros.Game.Stage do
  alias Heros.Utils

  @callback projection_for_session(session_id :: String.t(), game :: term) :: term

  @callback handle_call(request :: term, from :: GenServer.from(), game :: term) ::
              Utils.call_response()

  @callback handle_update(update :: term, from :: GenServer.from(), game :: term) ::
              Utils.call_response()

  @callback on_update(response :: Utils.call_response()) :: Utils.call_response()
end
