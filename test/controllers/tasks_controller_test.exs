defmodule Fyler.TasksControllerTest do
  use Fyler.ConnCase
  use ExUnit.Case
  import Fyler.ExUnit.AuthHelpers

  setup do
    {:ok, [auth_conn: auth_conn(build_conn(), insert(:user))]}
  end

  test "GET #index with pagination", %{auth_conn: auth_conn} do
    Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: insert(:project).id, source: "http://foo.example.com/files/foo.avi", type: "video"})
    response = get auth_conn, "/admin/tasks"

    pagination = %{"page_number" => 1, "page_size" => 20, "total_entries" => 1, "total_pages" => 1}
    assert %{"tasks" => _tasks, "pagination" => ^pagination} = json_response(response, 200)
  end

  test "GET #index filtered by category", %{auth_conn: auth_conn} do
    Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: insert(:project).id, source: "http://foo.example.com/files/foo.avi", type: "video"})    
    Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: insert(:project).id, source: "http://foo.example.com/files/bar.pdf", type: "pdf"})    
    Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: insert(:project).id, source: "http://foo.example.com/files/foo.pdf", type: "pdf"})

    response = get auth_conn, "/admin/tasks", %{category: "ffmpeg"}
    %{"tasks" => tasks, "pagination" => _pagination} = json_response(response, 200)
    
    assert length(tasks) == 1

    task = List.first(tasks)
    assert task["source"] == "http://foo.example.com/files/foo.avi"
    assert task["category"] == "ffmpeg"
  end

  test "GET #index filtered by category and type", %{auth_conn: auth_conn} do
    Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: insert(:project).id, source: "http://foo.example.com/files/foo.avi", type: "video"})    
    Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: insert(:project).id, source: "http://foo.example.com/files/bar.pdf", type: "pdf"})    
    Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: insert(:project).id, source: "http://foo.example.com/files/foo.pdf", type: "pdf"})

    response = get auth_conn, "/admin/tasks", %{category: "doc", type: "pdf"}
    %{"tasks" => tasks, "pagination" => _pagination} = json_response(response, 200)
    assert length(tasks) == 2
  end

  test "GET index with order", %{auth_conn: auth_conn} do
    t1 = Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: insert(:project).id, source: "http://foo.example.com/files/foo.avi", type: "video", iserted_at: Ecto.DateTime.cast!("2016-01-01 10:00:00")})
    Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: insert(:project).id, source: "http://foo.example.com/files/bar.pdf", type: "pdf", iserted_at: Ecto.DateTime.cast!("2016-01-01 10:20:00")})
    Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: insert(:project).id, source: "http://foo.example.com/files/foo.pdf", type: "pdf", iserted_at: Ecto.DateTime.cast!("2016-01-01 10:40:00")})

    response = get auth_conn, "/admin/tasks", %{"sort" => %{"inserted_at" => "asc"}}
    %{"tasks" => tasks, "pagination" => _pagination} = json_response(response, 200)
    assert List.first(tasks)["id"] == t1.id
  end
end
