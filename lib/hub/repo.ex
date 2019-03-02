defmodule Hub.Repo do
  use Ecto.Repo,
    otp_app: :hub,
		adapter: Ecto.Adapters.Postgres

	use Scrivener, page_size: 5
end
