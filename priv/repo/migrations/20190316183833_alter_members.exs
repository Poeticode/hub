defmodule Hub.Repo.Migrations.AlterMembers do
  use Ecto.Migration

	def change do
		alter table(:members) do
			add :email, :string
		end
	end
end
