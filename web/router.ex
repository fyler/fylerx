defmodule Fyler.Router do
  use Fyler.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipe_through :api

  post "/auth", Fyler.SessionsController, :create, as: "login"
end
