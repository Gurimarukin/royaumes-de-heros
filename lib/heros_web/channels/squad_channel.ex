defmodule HerosWeb.SquadChannel do
  alias Heros.{Squad, Squads}
  alias Heros.Utils.KeyList

  use Phoenix.Channel

  def join("squad:" <> squad_id, _message, socket) do
    case Squads.lookup(Squads, squad_id) do
      {:ok, squad_pid} ->
        user = socket.assigns.user
        socket = assign(socket, :squad_pid, squad_pid)

        case Squad.connect(squad_pid, user.id, user.name, self()) do
          {:ok, update} ->
            send(self(), {:update, update})
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
      {:ok, update} ->
        broadcast_update(update, socket)
        {:reply, :ok, socket}

      :error ->
        {:reply, :error, socket}
    end
  end

  def handle_info({:update, update}, socket) do
    broadcast_update(update, socket)
    {:noreply, socket}
  end

  intercept ["update"]

  def handle_out("update", %{update: {squad, event}}, socket) do
    projection =
      case squad.state do
        {:lobby, lobby} ->
          {:lobby, Heros.Lobby.Helpers.project(lobby, squad)}

        {:game, game} ->
          names = squad.members |> KeyList.map(& &1.name)
          {:game, Heros.Game.Helpers.project(game, socket.assigns.user.id, names)}
      end

    push(socket, "update", %{body: {projection, event}})
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    case socket.assigns[:squad_pid] do
      nil ->
        nil

      squad_pid ->
        case Squad.disconnect(squad_pid, self()) do
          {:ok, squad} -> broadcast_update(squad, socket)
        end
    end
  end

  defp broadcast_update(update, socket) do
    HerosWeb.Endpoint.broadcast!("squads", "update", %{})
    broadcast!(socket, "update", %{update: update})
  end
end
