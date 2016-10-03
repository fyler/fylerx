defmodule Fyler.ProjectsControllerTest do
  use Fyler.ConnCase
  use ExUnit.Case
  import Fyler.ExUnit.Helpers
  import Fyler.ExUnit.AuthHelpers

  setup do
    {:ok, [auth_conn: auth_conn(build_conn(), insert(:user))]}
  end

  test "POST create", %{auth_conn: auth_conn} do
    project_params = %{
      name: "FooBar",
      settings: %{}
    }

    response = post auth_conn, "/admin/projects", project: project_params
    assert %{"project" => %{"name" => "FooBar", "id" => _id, "api_key" => _key, "settings" => %{}}} = json_response(response, 200)
  end

  @tag :not_auth
  test "POST create (not_auth)" do
    response = post build_conn(), "/admin/projects", project: %{name: "Foo"}
    assert %{"errors" => "bad_token"} = json_response(response, 403)
  end

  test "POST create with invalid params", %{auth_conn: auth_conn} do
    project_params = %{
      settings: %{}
    }

    response = post auth_conn, "/admin/projects", project: project_params
    assert %{"errors" => ["name can't be blank"]} = json_response(response, 403)
  end

  test "POST create (with database assertion)", %{auth_conn: auth_conn} do
    event = fn -> post(auth_conn, "/admin/projects", project: %{name: "Foo"}) end
    change = fn -> Fyler.Project.count_records end
    assert is_changed(event, change, by: 1)
  end

  @tag :not_auth
  test "GET show (not_auth)" do
    project = insert(:project)
    response = get build_conn(), "/admin/projects/#{project.id}"
    assert %{"errors" => "bad_token"} = json_response(response, 403)
  end

  test "GET show", %{auth_conn: auth_conn} do
    project = insert(:project)
    response = get auth_conn, "/admin/projects/#{project.id}"
    id = project.id
    assert %{"project" => %{"name" => _name, "id" => ^id, "api_key" => _key, "settings" => %{}}} = json_response(response, 200)
  end

  test "GET show with invalid id", %{auth_conn: auth_conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get auth_conn, "/admin/projects/123"
    end
  end

  test "PATCH update", %{auth_conn: auth_conn} do
    project = insert(:project, name: "Foo", api_key: "12345")
    params = %{name: "updated", api_key: "123"}

    response = patch auth_conn, "/admin/projects/#{project.id}", project: params
    assert %{"project" => %{"name" => "updated", "api_key" => "12345"}} = json_response(response, 200)
  end

  @tag :not_auth
  test "PATCH update (not_auth)" do
    project = insert(:project, name: "Foo", api_key: "12345")
    params = %{name: "updated"}
    response = patch build_conn(), "/admin/projects/#{project.id}", project: params
    assert %{"errors" => "bad_token"} = json_response(response, 403)
  end

  test "DELETE delete", %{auth_conn: auth_conn} do
    project = insert(:project, name: "Foo")
    response = delete auth_conn, "/admin/projects/#{project.id}"

    assert %{"project" => %{"name" => "Foo"}} = json_response(response, 200)
  end

  test "DELETE delete (with database assertion)", %{auth_conn: auth_conn} do
    project = insert(:project, name: "Foo")
    event = fn -> delete(auth_conn, "/admin/projects/#{project.id}") end
    change = fn -> Fyler.Project.count_records end
    
    assert is_changed(event, change, by: -1)
  end

  @tag :not_auth
  test "DELETE delete (not_auth)" do
    project = insert(:project, name: "Foo")
    response = delete build_conn(), "/admin/projects/#{project.id}"
    assert %{"errors" => "bad_token"} = json_response(response, 403)
  end

  test "PATCH refresh", %{auth_conn: auth_conn} do
    project = insert(:project, name: "Foo", api_key: "12345")
    assert project.api_key == "12345"

    response = patch auth_conn, "/admin/projects/#{project.id}/refresh"
    %{"project" => resp} = json_response(response, 200)
    
    assert resp["api_key"] != "12345"
  end

  @tag :not_auth
  test "PATCH refresh (not_auth)" do
    project = insert(:project, name: "Foo", api_key: "12345")
    response = patch build_conn(), "/admin/projects/#{project.id}/refresh"
    assert %{"errors" => "bad_token"} = json_response(response, 403)
  end

  test "PATCH revoke", %{auth_conn: auth_conn} do
    project = insert(:project, name: "Foo", api_key: "12345")
    assert project.api_key == "12345"

    response = patch auth_conn, "/admin/projects/#{project.id}/revoke"
    assert %{"project" => %{"name" => "Foo", "api_key" => nil}} = json_response(response, 200)
  end

  @tag :not_auth
  test "PATCH revoke (not_auth)" do
    project = insert(:project, name: "Foo", api_key: "12345")
    response = patch build_conn(), "/admin/projects/#{project.id}/revoke"
    assert %{"errors" => "bad_token"} = json_response(response, 403)
  end
end
