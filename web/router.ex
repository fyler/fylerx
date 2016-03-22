defmodule Fyler.Router do
  use Fyler.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin" do
    pipe_through :api
    resources "/projects", Fyler.ProjectsController
    patch "/projects/:id/refresh", Fyler.ProjectsController, :refresh
    patch "/projects/:id/revoke", Fyler.ProjectsController, :revoke
  end

  pipe_through :api

  post "/auth", Fyler.SessionsController, :create, as: "login"
end
