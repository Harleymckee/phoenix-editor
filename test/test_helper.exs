ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Editor.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Editor.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Editor.Repo)

