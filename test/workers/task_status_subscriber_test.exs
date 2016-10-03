defmodule Fyler.TaskStatusSubscriberTest do
  use     ExUnit.Case, async: false
  use     Fyler.ModelCase
  import  Fyler.ExUnit.Helpers
  alias   Fyler.Task

  test ":gen_server updates task status to downloading" do
    params = %{project_id: insert(:project, settings: %{aws_id: "594", aws_secret: "secret_key1223"}).id, source: "s3://testbucket/music/metallica.mp3", type: "audio"}
    changeset = Task.create_changeset(%Task{}, params)
    {:ok, task} = Repo.insert(changeset)

    message = %{id: task.id, status: "downloading", data: %{worker_id: "127.0.0.1@fyler.worker"}}
    Fyler.ExrabbitHelper.send_to_queue("fyler.task.status", to_string(Poison.Encoder.encode(message, [])))
    
    wait_until fn ->
      updated = Repo.get_by(Task, id: task.id)
      assert updated.status == "downloading"
    end
  end

  test ":gen_server updates task status to processing" do
    params = %{project_id: insert(:project, settings: %{aws_id: "594", aws_secret: "secret_key1223"}).id, status: "downloading", source: "s3://testbucket/music/metallica.mp3", type: "audio"}
    changeset = Task.create_changeset(%Task{}, params)
    {:ok, task} = Repo.insert(changeset)

    message = %{id: task.id, status: "processing", data: %{download_time: 123892123, size: 239429}}
    Fyler.ExrabbitHelper.send_to_queue("fyler.task.status", to_string(Poison.Encoder.encode(message, [])))

    wait_until fn ->
      updated = Repo.get_by(Task, id: task.id)
      assert updated.status == "processing"
      assert updated.download_time == 123892123
      assert updated.file_size == 239429
    end
  end

  test ":gen_server updates task status to uploading" do
    params = %{project_id: insert(:project, settings: %{aws_id: "594", aws_secret: "secret_key1223"}).id, status: "processing", source: "s3://testbucket/music/metallica.mp3", type: "audio"}
    changeset = Task.create_changeset(%Task{}, params)
    {:ok, task} = Repo.insert(changeset)

    message = %{id: task.id, status: "uploading", data: %{process_time: 423892123}}
    Fyler.ExrabbitHelper.send_to_queue("fyler.task.status", to_string(Poison.Encoder.encode(message, [])))

    wait_until fn ->
      updated = Repo.get_by(Task, id: task.id)
      assert updated.status == "uploading"
      assert updated.process_time == 423892123
    end
  end
end
