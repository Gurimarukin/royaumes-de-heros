defmodule HerosWeb.SquadsChannel do
  use Phoenix.Channel

  alias Heros.Squads

  def join("squads", _message, socket) do
    {:ok, %{body: Squads.list(Squads)}, socket}
  end

  def handle_in("create", _message, socket) do
    # These should be returned for current user
    player_id = "p1"
    player_name = "Player 1"
    subscribe = fn -> nil end

    Squads.create(Squads, {player_id, player_name, subscribe})

    payload = %{body: Squads.list(Squads)}

    broadcast!(socket, "update", payload)
    {:noreply, socket}
  end

  intercept ["update"]

  def handle_out("update", msg, socket) do
    push(socket, "update", msg)
    {:noreply, socket}
  end
end
