defmodule Fyler.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Fyler.Repo
  
  alias Fyler.User
  alias Fyler.Project
  alias Fyler.Task

  def factory(:user) do
    %User{
      name: sequence(:name, &"user-#{&1}"),
      email: sequence(:email, &"email-#{&1}@fyler.com"),
      password: "qwerty",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("qwerty")
    }
  end

  def factory(:project) do
    %Project{
      name: sequence(:name, &"project-#{&1}"),
      settings: %{},
      api_key: Fyler.Token.generate()
    }
  end

  def factory(:task) do
    %Task{
      source: "http://foo.example.com/files/foo.avi",
      type: "video"
    }
  end
end
