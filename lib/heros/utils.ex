defmodule Heros.Utils do
  @type call_response ::
          {:reply, reply :: term, new_state :: term}
          | {:reply, reply :: term, new_state :: term, timeout | :hibernate | {:continue, term}}
          | {:noreply, new_state :: term}
          | {:noreply, new_state :: term, timeout | :hibernate | {:continue, term}}
          | {:stop, reason :: term, reply :: term, new_state :: term}
          | {:stop, reason :: term, new_state :: term}

  @spec map_call_response(response :: call_response(), (new_state :: term -> term)) ::
          call_response
  def map_call_response({:reply, reply, new_state}, f), do: {:reply, reply, f.(new_state)}

  def map_call_response({:reply, reply, new_state, timeout}, f),
    do: {:reply, reply, f.(new_state), timeout}

  def map_call_response({:noreply, new_state}, f), do: {:noreply, f.(new_state)}

  def map_call_response({:noreply, new_state, timeout}, f), do: {:noreply, f.(new_state), timeout}

  def map_call_response({:stop, reason, reply, new_state}, f),
    do: {:stop, reason, reply, f.(new_state)}

  def map_call_response({:stop, reason, new_state}, f), do: {:stop, reason, f.(new_state)}

  @spec flat_map_call_response(response :: call_response(), (new_state :: term -> call_response)) ::
          call_response
  def flat_map_call_response({:reply, _reply, new_state}, f), do: f.(new_state)
  def flat_map_call_response({:reply, _reply, new_state, _timeout}, f), do: f.(new_state)
  def flat_map_call_response({:noreply, new_state}, f), do: f.(new_state)
  def flat_map_call_response({:noreply, new_state, _timeout}, f), do: f.(new_state)
  def flat_map_call_response({:stop, _reason, _reply, new_state}, f), do: f.(new_state)
  def flat_map_call_response({:stop, _reason, new_state}, f), do: f.(new_state)

  def keyreplace(list, key, value), do: List.keyreplace(list, key, 0, {key, value})

  def keyupdate(list, key, f) do
    case List.keyfind(list, key, 0) do
      nil -> list
      {^key, previous} -> List.keyreplace(list, key, 0, {key, f.(previous)})
    end
  end

  def update_self_after(time, update) do
    slef = self()

    Task.start(fn ->
      Process.sleep(time)
      GenServer.call(slef, {:update, update})
    end)
  end
end
