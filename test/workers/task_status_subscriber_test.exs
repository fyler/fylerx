defmodule Fyler.TaskStatusSubscriberTest do
  use     ExUnit.Case, async: true
  use     Fyler.ModelCase
  import  Fyler.ExUnit.Helpers
  alias   Fyler.Task

  test ":gen_server updates task status to downloading" do
    params = %{project_id: create(:project, settings: %{aws_id: "594", aws_secret: "secret_key1223"}).id, source: "s3://testbucket/music/metallica.mp3", type: "audio"}
    changeset = Task.create_changeset(%Task{}, params)
    {:ok, task} = Repo.insert(changeset)

    message = %{id: task.id, status: "downloading", worker_id: "127.0.0.1@fyler.worker"}
    Fyler.ExrabbitHelper.send_to_queue("fyler.task.status", to_string(Poison.Encoder.encode(message, [])))
    
    wait_until fn ->
      updated = Repo.get_by(Task, id: task.id)
      assert updated.status == "downloading"
    end
  end
end
