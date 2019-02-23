# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Hub.Repo.insert!(%Hub.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Hub.Repo
alias Hub.Auth

Repo.delete_all(Auth.Admin)

admin = %Auth.Admin{}
    |> Auth.Admin.changeset(%{username: "judge", password: "asdf", emails: ["me@silentsilas.com"]})
    |> Repo.insert!()