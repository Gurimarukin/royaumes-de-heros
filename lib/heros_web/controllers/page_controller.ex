defmodule HerosWeb.PageController do
  use HerosWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
