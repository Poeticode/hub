defmodule Hub.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :name, :string
      add :website, :string
      add :approved, :boolean, default: false, null: false
      add :instagram, :string
      add :facebook, :string
      add :twitter, :string
      add :mastodon, :string
      add :bio, :text
      add :edit_url, :string

      timestamps()
    end

    create unique_index(:members, [:edit_url])
  end
end
