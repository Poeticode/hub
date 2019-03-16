defmodule Hub.Repo.Migrations.CreatePosts do
  use Ecto.Migration

	def change do
		alter table(:posts) do
			add :member_id, references(:members)
		end
		create index(:posts, [:member_id])
	end
end
