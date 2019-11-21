defmodule Hub.Repo.Migrations.AddTokenTimestampToMember do
  use Ecto.Migration

  def change do
		alter table(:members) do
      add :reset_token_timestamp, :utc_datetime
		end
  end
end
