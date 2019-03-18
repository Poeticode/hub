defmodule Hub.Repo.Migrations.AlterMembers do
  use Ecto.Migration

	def change do
		alter table(:members) do
      add :path, :string
      add :content_type, :string
      add :filename, :string
		end
	end
end
