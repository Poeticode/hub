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
            author: "Silas",
            title: "Super Deep",
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec leo nisl, pharetra sed mattis et, faucibus sit amet est. Maecenas suscipit ac nunc vitae vehicula. Maecenas vehicula leo odio. In tempus ornare eros pulvinar consequat. Mauris non erat sed libero viverra sagittis et at dui. Ut posuere arcu in varius dictum. Nam accumsan sapien eu ante dapibus, sed molestie eros placerat. Vivamus vehicula, dolor sed laoreet consectetur, arcu libero tristique nibh, at finibus urna tellus sit amet urna. Sed vestibulum lacus vel metus dapibus, interdum ultrices libero pretium. Fusce eu tortor ut turpis blandit placerat. Praesent nibh quam, lobortis id commodo in, maximus ut sapien. Aliquam at tellus lorem. Aliquam eget ex nec est placerat varius malesuada id erat. Aliquam varius consequat nulla vitae placerat. Nullam libero felis, bibendum non purus eget, posuere molestie ante.",
            approved: true
        })
    |> Repo.insert!()

unapproved_post = %Content.Post{}
    |> Content.Post.changeset(%{
            author: "Not Silas",
            title: "Not So Deep",
            content: "Cras a tincidunt urna, sed congue nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris lacinia facilisis mattis. Morbi interdum imperdiet nisl vitae molestie. In mollis cursus magna. Donec vel posuere orci, et feugiat urna. Maecenas nec lobortis nulla, vel ultrices erat. Aliquam quis nisl sagittis, maximus odio eu, gravida dolor. Suspendisse aliquam mi faucibus est lacinia, vitae lacinia lorem ultrices. Quisque tincidunt mi sit amet purus ultrices blandit. Pellentesque lorem est, iaculis ut purus eu, condimentum pellentesque justo.",
            approved: false
        })
    |> Repo.insert!()