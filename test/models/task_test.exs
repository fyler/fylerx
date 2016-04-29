defmodule Fyler.TaskTest do
  use Fyler.ModelCase

  alias Fyler.Task

  @valid_create_attrs %{project_id: create(:project).id, source: "http://foo.example.com/files/foo.avi", type: "video"}

  test "#insert creates with default status" do
    changeset = Task.create_changeset(%Task{}, @valid_create_attrs)
    task = Fyler.Repo.insert!(changeset)
    assert task.status == "idle"
  end

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
    params = %{project_id: create(:project).id, source: "http://foo.example.com/files/foo.avi", type: "pipe", category: "document"}
    changeset = Task.create_changeset(%Task{}, params)
    assert changeset.valid?
    assert changeset.changes[:category] == "document"
    assert changeset.changes[:type] == "pipe"
  end

  test "#create_changeset with pipe (without category)" do
    params = %{project_id: create(:project).id, source: "http://foo.example.com/files/foo.avi", type: "pipe"}
    changeset = Task.create_changeset(%Task{}, params)
    refute changeset.valid?
    assert changeset.errors == [category: "can't be blank"]
  end

  test "#create_changeset without type" do
    params = %{project_id: create(:project).id, source: "http://foo.example.com/files/foo.avi"}
    changeset = Task.create_changeset(%Task{}, params)
    refute changeset.valid?
    assert changeset.errors == [type: "can't be blank", category: "can't be blank"]
  end

  test "#create_changeset without project" do
    params = %{source: "http://foo.example.com/files/foo.avi", type: "pipe", category: "document"}
    changeset = Task.create_changeset(%Task{}, params)
    refute changeset.valid?
    assert changeset.errors == [project_id: "can't be blank"]
  end

  test "#create_changeset when type not inclusion" do
    params = %{project_id: create(:project).id, source: "http://foo.example.com/files/foo.avi", type: "foo"}
    changeset = Task.create_changeset(%Task{}, params)
    refute changeset.valid?
    assert changeset.errors == [type: "is invalid"]
  end

  test "#create_changeset when URL is invalid" do
    params = %{project_id: create(:project).id, source: ".foo/bar", type: "video"}
    changeset = Task.create_changeset(%Task{}, params)
    refute changeset.valid?
    assert changeset.errors == [source: "has invalid format"]
  end

  test "#create_changeset when URL is s3" do
    params = %{project_id: create(:project).id, source: "s3://foo.example.com/files/foo.avi", type: "video"}
    changeset = Task.create_changeset(%Task{}, params)
    assert changeset.valid?
  end

  test "#transform with default output" do
    params = %{project_id: create(:project, settings: %{aws_id: "123", aws_secret: "dais0f9sd"}).id, source: "s3://buckettest/my/files/foo.avi", type: "video"}
    changeset = Task.create_changeset(%Task{}, params)
    {:ok, task} = Repo.insert(changeset)
    
    id = task.id

    %{id: ^id, name: name, extension: extension, source: source, output: output} = Task.transform(task)

    assert source[:bucket] == "buckettest"
    assert source[:prefix] == "my/files/foo.avi"
    assert source[:type] == "s3"

    assert output[:bucket] == "buckettest"
    assert output[:prefix] == "my/files"
    assert output[:type] == "s3"

    assert source[:credentials] == output[:credentials]
    assert source[:credentials][:aws_id] == "123"
    assert source[:credentials][:aws_secret] == "dais0f9sd"

    assert name == "foo"
    assert extension == "avi"
  end

  test "#transform with output" do
    params = %{
      project_id: create(:project, settings: %{aws_id: "123", aws_secret: "dais0f9sd"}).id,
      source: "s3://buckettest/my/files/foo.avi",
      data: %{"output" => "s3://buckettest/my/files/converted"},
      type: "video"
    }

    changeset = Task.create_changeset(%Task{}, params)
    {:ok, task} = Repo.insert(changeset)

    assert %{output: output} = Task.transform(task)
    assert output[:bucket] == "buckettest"
    assert output[:prefix] == "my/files/converted"
    assert output[:type] == "s3"
    assert output[:credentials][:aws_id] == "123"
    assert output[:credentials][:aws_secret] == "dais0f9sd"
  end

  test "#transform when source without protocol" do
    params = %{project_id: create(:project).id, source: "buckettest.com/my/files/foo.avi", type: "video"}
    changeset = Task.create_changeset(%Task{}, params)
    {:ok, task} = Repo.insert(changeset)

    assert %{source: source, output: output} = Task.transform(task)
    assert source[:prefix] == "buckettest.com/my/files/foo.avi"
  end

  test "#makr_as change status" do
    params = %{project_id: create(:project, settings: %{aws_id: "123", aws_secret: "dais0f9sd"}).id, source: "s3://buckettest/my/files/foo.avi", type: "video"}
    changeset = Task.create_changeset(%Task{}, params)
    {:ok, task} = Repo.insert(changeset)

    {:ok, updated} = Task.mark_as(:queued, task)
    assert updated.status == "queued"
  end

  test "#makr_as does not change status if it's undefined" do
    params = %{project_id: create(:project, settings: %{aws_id: "123", aws_secret: "dais0f9sd"}).id, source: "s3://buckettest/my/files/foo.avi", type: "video"}
    changeset = Task.create_changeset(%Task{}, params)
    {:ok, task} = Repo.insert(changeset)

    assert {:error, _} = Task.mark_as(:barbaz, task)
  end

  test "#send_to_queue" do
    params = %{project_id: create(:project, settings: %{aws_id: "123", aws_secret: "dais0f9sd"}).id, source: "s3://buckettest/my/files/foo.avi", type: "video"}
    changeset = Task.create_changeset(%Task{}, params)
    {:ok, task} = Repo.insert(changeset)

    assert :ok = Task.send_to_queue(task)
  end
end
