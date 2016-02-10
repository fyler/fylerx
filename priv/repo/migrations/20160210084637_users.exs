defmodule Fyler.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :encrypted_password, :string

      timestamps
    end

    execute("CREATE UNIQUE INDEX index_users_on_email ON users (lower(email))")
  end
end
