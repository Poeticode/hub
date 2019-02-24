defmodule Hub.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :author, :string
      add :title, :string
      add :content, :text
      add :approved, :boolean, default: false, null: false

      timestamps()
    end
 
  end
end
