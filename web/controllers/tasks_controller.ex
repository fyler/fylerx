defmodule Fyler.TasksController do
  use Fyler.Web, :controller

  alias Fyler.Task

  def index(conn, params) do
    page = Task
           |> Task.by_project(params["project_id"])
           |> Task.by_status(params["status"])
           |> Task.by_category(params["category"])
           |> Task.with_order(params["sort"])
           |> Repo.paginate(page: params["page"])

    render conn, "index.json", page
  end
end
