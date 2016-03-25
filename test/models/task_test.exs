defmodule Fyler.TaskTest do
  use Fyler.ModelCase

  alias Fyler.Task

  @valid_create_attrs %{source: "http://foo.example.com/files/foo.avi", type: "video"}

  test "#create_changeset with valid attributes" do
    changeset = Task.create_changeset(%Task{}, @valid_create_attrs)
    assert changeset.valid?
  end

  test "#create_changeset creates category" do
    changeset = Task.create_changeset(%Task{}, @valid_create_attrs)
    assert changeset.valid?
    assert changeset.changes[:category] == "ffmpeg"
  end

  test "#create_changeset with pipe type" do
    params = %{source: "http://foo.example.com/files/foo.avi", type: "pipe", category: "document"}
    changeset = Task.create_changeset(%Task{}, params)
    assert changeset.valid?
    assert changeset.changes[:category] == "document"
    assert changeset.changes[:type] == "pipe"
  end

  test "#create_changeset with pipe (without category)" do
    params = %{source: "http://foo.example.com/files/foo.avi", type: "pipe"}
    changeset = Task.create_changeset(%Task{}, params)
    refute changeset.valid?
    assert changeset.errors == [category: "can't be blank"]
  end

  test "#create_changeset without type" do
    params = %{source: "http://foo.example.com/files/foo.avi"}
    changeset = Task.create_changeset(%Task{}, params)
    refute changeset.valid?
    assert changeset.errors == [type: "can't be blank", category: "can't be blank"]
  end

  test "#create_changeset when type not inclusion" do
    params = %{source: "http://foo.example.com/files/foo.avi", type: "foo"}
    changeset = Task.create_changeset(%Task{}, params)
    refute changeset.valid?
    assert changeset.errors == [type: "is invalid"]
  end

  test "#create_changeset when URL is invalid" do
    params = %{source: "foo/bar", type: "video"}
    changeset = Task.create_changeset(%Task{}, params)
    refute changeset.valid?
    assert changeset.errors == [source: "has invalid format"]
  end

  test "#create_changeset when URL is s3" do
    params = %{source: "s3://foo.example.com/files/foo.avi", type: "video"}
    changeset = Task.create_changeset(%Task{}, params)
    assert changeset.valid?
  end
end
