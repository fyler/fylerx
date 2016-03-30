defmodule Fyler.Api.TasksController do
  use Fyler.Web, :controller

  alias Fyler.Task

  def show(conn, %{"id" => id}) do
    render conn, "show.json", data: Repo.get!(Task, id)
  end

  def create(conn, %{"task" => params}) do
    changeset = Task.create_changeset(%Task{}, params)
    
    case Repo.insert(changeset) do
      {:ok, task} ->
        render conn, "create.json", data: task
      {:error, changeset} ->
        conn
        |> put_status(403)
        |> render("error.json", changeset: changeset)
    end
  end
end
