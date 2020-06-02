defmodule HerosWeb.SquadChannel do
  alias Heros.{Squad, Squads}

  use Phoenix.Channel

  def join("squad:" <> squad_id, _message, socket) do
    case Squads.lookup(Squads, squad_id) do
      {:ok, squad_pid} ->
        user = socket.assigns.user
        socket = assign(socket, :squad_pid, squad_pid)

        case Squad.connect(squad_pid, user.id, user.name, self()) do
          {:ok, squad} ->
            send(self(), {:update, squad})
            {:ok, socket}

          :error ->
            {:error, %{status: 403}}
        end

      _ ->
        {:error, %{status: 404}}
    end
  end

  def handle_in("call", message, socket) do
    case GenServer.call(socket.assigns.squad_pid, {socket.assigns.user.id, message}) do
      {:ok, squad} ->
        broadcast_update(squad, socket)
        {:reply, :ok, socket}

      :error ->
        {:reply, :error, socket}
    end
  end

  def handle_info({:update, squad}, socket) do
    broadcast_update(squad, socket)
    {:noreply, socket}
  end

  intercept ["update"]

  def handle_out("update", msg, socket) do
    push(socket, "update", msg)
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    case socket.assigns[:squad_pid] do
      nil ->
        nil

      squad_pid ->
        case Squad.disconnect(squad_pid, socket.assigns.user.id, self()) do
          {:ok, squad} -> broadcast_update(squad, socket)
        end
    end
  end

  defp broadcast_update(squad, socket) do
    HerosWeb.Endpoint.broadcast!("squads", "update", %{})

    projection =
      case squad.state do
        {:lobby, lobby} -> {:lobby, Heros.Lobby.Helpers.project(lobby, squad)}
        {:game, game} -> {:game, Heros.Game.Helpers.project(game, socket.assigns.user.id)}
      end

    broadcast!(socket, "update", %{body: projection})
  end
end