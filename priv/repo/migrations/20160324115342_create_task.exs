defmodule Fyler.Repo.Migrations.CreateTask do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION \"uuid-ossp\""

    create table(:tasks, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :status, :string, default: "idle"
      add :type, :string
      add :category, :string
      add :source, :string
      add :worker_id, :string
      add :data, :map
      add :result, :map

      # stats
      add :queue_time, :integer
      add :download_time, :integer
      add :process_time, :integer
      add :upload_time, :integer
      add :total_time, :integer

      timestamps
    end
  end

  def down do
    execute "DROP EXTENSION IF EXISTS \"uuid-ossp\""
    drop table(:tasks)
  end
end
