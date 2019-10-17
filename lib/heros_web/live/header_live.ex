defmodule HerosWeb.HeaderLive do
  use Phoenix.LiveView

  def mount(%{user_name: user_name}, socket) do
    {:ok, assign(socket, user_name: user_name, edit_name: false)}
  end

  def render(assigns) do
    HerosWeb.LayoutView.render("header.html", assigns)
  end

  def handle_event("edit_name", _params, socket) do
    {:noreply, assign(socket, edit_name: true)}
  end

  def handle_event("submit_name", %{"value" => name}, socket) do
    name = String.trim(name)

    socket =
      if String.length(name) > 0 do
        assign(socket, user_name: name)
      else
        socket
      end

    {:noreply, assign(socket, edit_name: false)}
  end

  def handle_event("keyup_name", %{"key" => "Enter", "value" => name}, socket) do
    handle_event("submit_name", %{"value" => name}, socket)
  end

  def handle_event("keyup_name", %{"key" => "Escape"}, socket) do
    {:noreply, assign(socket, edit_name: false)}
  end

  def handle_event("keyup_name", _params, socket) do
    {:noreply, socket}
  end
end
