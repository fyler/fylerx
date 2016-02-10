# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fyler.Repo.insert!(%Fyler.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Fyler.Repo.insert!(
  Fyler.User.create_changeset(
    %Fyler.User{},
    %{name: "fAdmin", email: "fyler@tb.com", password: "qwerty"}
  )
)