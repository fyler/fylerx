defmodule Fyler.Router do
  use Fyler.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Fyler do
    pipe_through :api
  end
end
