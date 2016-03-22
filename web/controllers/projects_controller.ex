defmodule Fyler.ProjectsController do
  use Fyler.Web, :controller

  alias Fyler.Project

  def create(conn, %{"project" => params}) do
    changeset = Project.create_changeset(%Project{}, params)
    
    case Repo.insert(changeset) do
      {:ok, project} ->
        render conn, "create.json", data: project
      {:error, changeset} ->
        conn
        |> put_status(403)
        |> render("error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    render conn, "show.json", data: Repo.get!(Project, id)
  end

  def update(conn, %{"id" => id, "project" => params}) do
    project = Repo.get!(Project, id)
    changeset = Project.update_changeset(project, params)

    case Repo.update(changeset) do
      {:ok, project} ->
        render conn, "show.json", data: project
      {:error, changeset} ->
        conn
        |> put_status(403)
        |> render("error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    case Repo.delete(project) do
      {:ok, project} ->
        render conn, "show.json", data: project
      _ ->
        send_errors(conn, :access_denied, 403)
    end
  end

  def refresh(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    changeset = Project.refresh_changeset(project)

    case Repo.update(changeset) do
      {:ok, project} ->
        render conn, "show.json", data: project
      {:error, changeset} ->
        conn
        |> put_status(403)
        |> render("error.json", changeset: changeset)
    end
  end

  def revoke(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    changeset = Project.revoke_changeset(project)
    
    case Repo.update(changeset) do
      {:ok, project} ->
        render conn, "show.json", data: project
      {:error, changeset} ->
        conn
        |> put_status(403)
        |> render("error.json", changeset: changeset)
    end
  end
end
