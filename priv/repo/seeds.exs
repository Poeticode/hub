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
alias Hub.Content

Repo.delete_all(Auth.Admin)
Repo.delete_all(Content.Post)

admin = %Auth.Admin{}
    |> Auth.Admin.changeset(%{username: "judge", password: "asdf", emails: ["me@silentsilas.com"]})
    |> Repo.insert!()

post = %Content.Post{}
    |> Content.Post.changeset(%{
            author: "Some Poet",
            title: "Some Title",
            content: "Some content",
            approved: true
        })
    |> Repo.insert!()

unapproved_post = %Content.Post{}
    |> Content.Post.changeset(%{
            author: "Another Poet",
            title: "Another Title",
            content: "More content",
            approved: false
        })
    |> Repo.insert!()