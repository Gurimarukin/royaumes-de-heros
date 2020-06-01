defmodule HerosWeb.Router do
  use HerosWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HerosWeb.Session
    plug :put_user_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HerosWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", HerosWeb do
  #   pipe_through :api
  # end

  defp put_user_token(conn, _) do
    if user = conn.assigns[:user] do
      token = Phoenix.Token.sign(conn, "user socket", %{id: user.id, name: user.name})
      assign(conn, :user, Map.put(user, :token, token))
    else
      conn
    end
  end
end
