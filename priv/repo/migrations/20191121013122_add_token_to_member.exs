defmodule Hub.Repo.Migrations.AddTokenToMember do
  use Ecto.Migration

  def change do
		alter table(:members) do
      add :reset_token, :string
		end
  end
end
