defmodule HerosWeb.SquadChannel do
  alias Heros.{Squad, Squads}

  use Phoenix.Channel

  def join("squad:" <> squad_id, _message, socket) do
    case Squads.lookup(Squads, squad_id) do
      {:ok, squad_pid} ->
        user = socket.assigns[:user]

        case Squad.connect(squad_pid, user.id, user.name, self()) do
          {:ok, state} ->
            state = body(state)

            send(self(), {:update, state})

            socket = assign(socket, :squad_pid, squad_pid)
            {:ok, state, socket}

          :error ->
            {:error, %{status: 403}}
        end

      _ ->
        {:error, %{status: 404}}
    end
  end

  # def handle_in("create", _message, socket) do
  #   id = Squads.create(Squads)

  #   broadcast!(socket, "update", %{body: Squads.list(Squads)})
  #   {:reply, {:ok, %{id: id}}, socket}
  # end

  def handle_info({:update, state}, socket) do
    broadcast_update(state, socket)
    {:noreply, socket}
  end

  intercept ["update"]

  def handle_out("update", msg, socket) do
    push(socket, "update", msg)
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    case Squad.disconnect(socket.assigns.squad_pid, socket.assigns.user.id, self()) do
      {:ok, state} -> broadcast_update(body(state), socket)
    end
  end

  defp broadcast_update(state, socket) do
    HerosWeb.Endpoint.broadcast!("squads", "update", %{})
    broadcast!(socket, "update", state)
  end

  defp body(state) do
    %{body: state}
  end
end
