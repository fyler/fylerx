defmodule Fyler.ProjectTest do
  use Fyler.ModelCase

  alias Fyler.Project

  @valid_attrs %{api_key: "some content", name: "some content", settings: %{}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Project.changeset(%Project{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Project.changeset(%Project{}, @invalid_attrs)
    refute changeset.valid?
  end
end
