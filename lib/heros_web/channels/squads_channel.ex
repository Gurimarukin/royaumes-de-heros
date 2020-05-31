defmodule HerosWeb.SquadsChannel do
  use Phoenix.Channel

  alias Heros.Squads

  def join("squads", _message, socket) do
    {:ok, %{body: Squads.list(Squads)}, socket}
  end

  def handle_in("create", _message, socket) do
    id = Squads.create(Squads)

    broadcast!(socket, "update", %{body: Squads.list(Squads)})
    {:reply, {:ok, %{id: id}}, socket}
  end

  intercept ["update"]

  def handle_out("update", msg, socket) do
    push(socket, "update", msg)
    {:noreply, socket}
  end
end
