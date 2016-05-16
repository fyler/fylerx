defmodule Fyler.Api.TasksController do
  use Fyler.Web, :controller

  alias Fyler.Task

  def show(conn, %{"id" => id}) do
    render conn, "show.json", data: Repo.get!(Task, id)
  end

  def create(conn, %{"task" => params}) do
    # changeset = Task.create_changeset(%Task{}, Map.merge(params, %{project_id: project_id(conn)}))
    # case Repo.insert(changeset) do
    #   {:ok, task} ->
    #     render conn, "create.json", data: task
    #   {:error, changeset} ->
    #     conn
    #     |> put_status(403)
    #     |> render("error.json", changeset: changeset)
    # end

    case Task.create_and_send_to_queue(%Task{}, Map.merge(params, %{project_id: project_id(conn)})) do
      {:ok, task} ->
        render conn, "create.json", data: task
      {:error, changeset} ->
        conn
        |> put_status(403)
        |> render("error.json", changeset: changeset)
    end
  end

  defp project_id(conn) do
    conn.assigns[:current_project_id]
  end
end
