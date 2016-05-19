defmodule Fyler.Repo.Migrations.CreateTask do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION \"uuid-ossp\""

    create table(:tasks, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :status, :string
      add :type, :string
      add :category, :string
      add :source, :string
      add :worker_id, :string
      add :data, :map
      add :result, :map
      add :project_id, :integer
      add :file_size, :integer

      # stats
      add :queue_time, :integer
      add :download_time, :integer
      add :process_time, :integer
      add :upload_time, :integer
      add :total_time, :integer
      add :total_task_time, :integer

      timestamps
    end

    create index(:tasks, [:project_id])
  end

  def down do
    drop table(:tasks)
    execute "DROP EXTENSION IF EXISTS \"uuid-ossp\""
  end
end
