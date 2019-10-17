defmodule HerosWeb.Router do
  use HerosWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HerosWeb.Session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HerosWeb do
    pipe_through :browser

    get "/", GamesController, :index
    get "/game/test", TestGameController, :show
    get "/game/:id", GameController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", HerosWeb do
  #   pipe_through :api
  # end
end
