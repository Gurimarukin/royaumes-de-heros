defmodule HerosWeb.SquadsChannel do
  use Phoenix.Channel

  def join("squads", _message, socket) do
    {:ok, Heros.Squads.list(Heros.Squads), socket}
  end
end
