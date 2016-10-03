defmodule Fyler.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Fyler.Repo
  
  alias Fyler.User
  alias Fyler.Project
  alias Fyler.Task

  def user_factory() do
    %User{
      name: sequence(:name, &"user-#{&1}"),
      email: sequence(:email, &"email-#{&1}@fyler.com"),
      password: "qwerty",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("qwerty")
    }
  end

  def project_factory() do
    %Project{
      name: sequence(:name, &"project-#{&1}"),
      settings: %{},
      api_key: Fyler.Token.generate()
    }
  end

  def task_factory() do
    %Task{
      source: "http://foo.example.com/files/foo.avi",
      type: "video"
    }
  end
end
