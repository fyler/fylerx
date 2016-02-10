defmodule Fyler.Repo.Migrations.CreateProject do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :api_key, :string
      add :settings, :map

      timestamps
    end

    create unique_index(:projects, [:api_key])
  end
end
