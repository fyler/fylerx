defmodule Fyler.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Fyler.Repo
  alias Fyler.User

  def factory(:user) do
    %User{
      name: sequence(:name, &"user-#{&1}"),
      email: sequence(:email, &"email-#{&1}@fyler.com"),
      password: "qwerty"
    }
  end
end
