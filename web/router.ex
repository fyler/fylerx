defmodule Fyler.Router do
  use Fyler.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :project_auth do
    plug Fyler.Plugs.ProjectAuth
  end

  pipeline :admin do
    plug Fyler.Plugs.AdminAuth
  end

  scope "/admin" do
    pipe_through :api
    pipe_through :admin
    
    resources "/projects", Fyler.ProjectsController
    patch "/projects/:id/refresh", Fyler.ProjectsController, :refresh
    patch "/projects/:id/revoke", Fyler.ProjectsController, :revoke

    resources "/tasks", Fyler.TasksController, only: [:index]

    resources "/presets", Fyler.PresetsController
  end

  scope "/api", alias: Fyler.Api, as: :api do
    pipe_through :api
    pipe_through :project_auth

    resources "/tasks", TasksController, only: [:create, :show]
  end

  pipe_through :api

  post "/auth", Fyler.SessionsController, :create, as: "login"
end
