defmodule HerosWeb.PageController do
  use HerosWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:json_user, Jason.encode!(conn.assigns[:user]))
    |> assign(:card_data, Jason.encode!(Heros.Game.Cards.Card.data()))
    |> assign(:csrf_token, Jason.encode!(get_csrf_token()))
    |> render("index.html")
  end
end
