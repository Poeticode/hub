defmodule Hub.Repo.Migrations.CreateAdmins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add :username, :string
      add :password_hash, :string
      add :emails, {:array, :string}

      timestamps()
    end

  end
end
