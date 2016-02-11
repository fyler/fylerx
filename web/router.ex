defmodule Fyler.Router do
  use Fyler.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Fyler do
    pipe_through :api

    post "/auth", SessionsController, :create, as: "login"
    delete "/auth", SessionsController, :delete, as: "logout"
  end
end
