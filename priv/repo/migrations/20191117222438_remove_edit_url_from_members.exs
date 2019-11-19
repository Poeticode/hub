defmodule Hub.Repo.Migrations.RemoveEditUrlFromMembers do
  use Ecto.Migration

  def change do
    drop unique_index(:members, [:edit_url])
    create unique_index(:members, [:email])

    alter table(:members) do
      add :password_hash, :string
    end
  end
end



