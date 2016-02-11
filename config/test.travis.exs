use Mix.Config

import_config "test.exs"

# Configure your database
config :fyler, Fyler.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  database: "fyler_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
