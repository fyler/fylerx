defmodule Fyler.Api.TasksControllerTest do
  use Fyler.ConnCase
  use ExUnit.Case
  import Fyler.ExUnit.Helpers
  import Fyler.ExUnit.AuthHelpers

  setup do
    project = create(:project)
    {:ok, [auth_conn: auth_with_token(conn(), project.api_key)]}
  end

  test "POST #create", %{auth_conn: auth_conn} do
    params = %{
      type: "video",
      source: "http://foo.example.com/files/foo.avi",
      data: %{ format: "mp4" }
    }

    response = post auth_conn, "/api/tasks", task: params
    assert %{"task" => %{"id" => _id}} = json_response(response, 200)
  end

  test "POST create (with database assertion)", %{auth_conn: auth_conn} do
    params = %{
      type: "video",
      source: "http://foo.example.com/files/foo.avi",
      data: %{ format: "mp4" }
    }

    event = fn -> post(auth_conn, "/api/tasks", task: params) end
    change = fn -> Fyler.Repo.one(from p in Fyler.Task, select: count(p.id)) end
    assert is_changed(event, change, by: 1)
  end

  test "POST #create (with invalid params)", %{auth_conn: auth_conn} do
    params = %{
      type: "video",
      data: %{ format: "mp4" }
    }

    response = post auth_conn, "/api/tasks", task: params
    assert %{"errors" => ["source can't be blank"]} = json_response(response, 403)
  end

  @tag :not_auth
  test "POST #create (without auth)" do
    params = %{
      type: "video",
      source: "http://foo.example.com/files/foo.avi",
      data: %{ format: "mp4" }
    }

    response = post conn(), "/api/tasks", tasks: params
    assert %{"errors" => "bad_token"} = json_response(response, 403)
  end

  test "GET #show", %{auth_conn: auth_conn} do
    task = Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: create(:project).id, source: "http://foo.example.com/files/foo.avi", type: "video"})
    response = get auth_conn, "/api/tasks/#{task.id}"
    id = task.id
    assert %{"task" => %{"id" => ^id, "type" => "video", "category" => "ffmpeg"}} = json_response(response, 200)
  end

  @tag :not_auth
  test "GET #show (without auth)" do
    task = Fyler.Repo.insert! Fyler.Task.create_changeset(%Fyler.Task{}, %{project_id: create(:project).id, source: "http://foo.example.com/files/foo.avi", type: "video"})
    response = get conn(), "/api/tasks/#{task.id}"
    assert %{"errors" => "bad_token"} = json_response(response, 403)
  end
end
