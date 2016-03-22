defmodule Fyler.ProjectsControllerTest do
  use Fyler.ConnCase
  import Fyler.ExUnit.Helpers

  test "POST create" do
    project_params = %{
      name: "FooBar",
      settings: %{}
    }

    response = post conn(), "/admin/projects", project: project_params
    assert %{"project" => %{"name" => "FooBar", "id" => _id, "api_key" => _key, "settings" => %{}}} = json_response(response, 200)
  end

  test "POST create with invalid params" do
    project_params = %{
      settings: %{}
    }

    response = post conn(), "/admin/projects", project: project_params
    assert %{"errors" => ["name can't be blank"]} = json_response(response, 403)
  end

  test "POST create (with database assertion)" do
    event = fn -> post(conn(), "/admin/projects", project: %{name: "Foo"}) end
    change = fn -> Fyler.Project.count_records end
    assert is_changed(event, change, by: 1)
  end

  test "GET show" do
    project = create(:project)
    response = get conn(), "/admin/projects/#{project.id}"
    id = project.id
    assert %{"project" => %{"name" => _name, "id" => ^id, "api_key" => _key, "settings" => %{}}} = json_response(response, 200)
  end

  test "GET show with invalid id" do
    assert_raise Ecto.NoResultsError, fn ->
      get conn(), "/admin/projects/123"
    end
  end

  test "PATCH update" do
    project = create(:project, name: "Foo", api_key: "12345")
    params = %{name: "updated", api_key: "123"}

    response = patch conn(), "/admin/projects/#{project.id}", project: params
    assert %{"project" => %{"name" => "updated", "api_key" => "12345"}} = json_response(response, 200)
  end

  test "DELETE delete" do
    project = create(:project, name: "Foo")
    response = delete conn(), "/admin/projects/#{project.id}"

    assert %{"project" => %{"name" => "Foo"}} = json_response(response, 200)
  end

  test "DELETE delete (with database assertion)" do
    project = create(:project, name: "Foo")
    event = fn -> delete(conn(), "/admin/projects/#{project.id}") end
    change = fn -> Fyler.Project.count_records end
    
    assert is_changed(event, change, by: -1)
  end

  test "PATCH refresh" do
    project = create(:project, name: "Foo", api_key: "12345")
    assert project.api_key == "12345"

    response = patch conn(), "/admin/projects/#{project.id}/refresh"
    %{"project" => resp} = json_response(response, 200)
    
    assert resp["api_key"] != "12345"
  end

  test "PATCH revoke" do
    project = create(:project, name: "Foo", api_key: "12345")
    assert project.api_key == "12345"

    response = patch conn(), "/admin/projects/#{project.id}/revoke"
    assert %{"project" => %{"name" => "Foo", "api_key" => nil}} = json_response(response, 200)
  end
end
