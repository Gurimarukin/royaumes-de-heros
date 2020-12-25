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
    broadcast_if_ok(
      GenServer.call(socket.assigns.squad_pid, {socket.assigns.user.id, message}),
      socket
    )
  end

  def handle_in("leave", _message, socket) do
    broadcast_if_ok(Squad.leave(socket.assigns.squad_pid, socket.assigns.user.id), socket)
  end

  def handle_info({:update, update}, socket) do
    broadcast_update(update, socket)
    {:noreply, socket}
  end

  intercept ["update"]

  def handle_out("update", %{update: {squad, event}}, socket) do
    names = squad.members |> KeyList.map(& &1.name)

    projection =
      case squad.state do
        {:lobby, lobby} ->
          {:lobby, Heros.Lobby.Helpers.project(lobby, squad, names)}

        {:game, game} ->
          {:game, Heros.Game.Helpers.project(game, socket.assigns.user.id, names)}

        {:won, game} ->
          {:won, Heros.Game.Helpers.project(game, socket.assigns.user.id, names)}
      end

    push(socket, "update", %{body: {projection, event}})
    {:noreply, socket}
  end

  defp broadcast_if_ok(:error, socket), do: {:reply, :error, socket}

  defp broadcast_if_ok({:ok, update}, socket) do
    broadcast_update(update, socket)
    {:reply, :ok, socket}
  end

  defp broadcast_update(update, socket) do
    HerosWeb.Endpoint.broadcast!("squads", "update", %{})
    broadcast!(socket, "update", %{update: update})
  end
end
