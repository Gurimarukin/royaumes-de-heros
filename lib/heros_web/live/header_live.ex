defmodule HerosWeb.HeaderLive do
  use Phoenix.LiveView

  def mount(session, socket) do
    {:ok, assign(socket, session: session)}
  end

  def render(assigns) do
    HerosWeb.LayoutView.render("header.html", assigns)
  end
end
