defmodule HerosWeb.SquadsChannel do
  alias Heros.Squads

  use Phoenix.Channel

  def join("squads", _message, socket) do
    {:ok, squads_list(), socket}
  end

  def handle_in("create", _message, socket) do
    id = Squads.create(Squads)
    broadcast_update(socket)
    {:reply, {:ok, %{id: id}}, socket}
  end

  intercept ["update"]

  def handle_out("update", _msg, socket) do
    push(socket, "update", squads_list())
    {:noreply, socket}
  end

  defp broadcast_update(socket) do
    broadcast!(socket, "update", %{})
  end

  defp squads_list do
    %{body: Squads.list(Squads)}
  end
end
