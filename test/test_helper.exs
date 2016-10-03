ExUnit.start()
Mix.Task.run "ecto.create", ~w(-r Fyler.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Fyler.Repo --quiet)
Ecto.Adapters.SQL.Sandbox.mode(Fyler.Repo, :manual)

