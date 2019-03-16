defmodule Hub.Auth.Member do
  use Ecto.Schema
  import Ecto.Changeset


  schema "members" do
    field :approved, :boolean, default: false
    field :bio, :string
    field :edit_url, :string
    field :facebook, :string
    field :instagram, :string
    field :mastodon, :string
    field :name, :string
    field :twitter, :string
		field :website, :string
		has_many :posts, Hub.Content.Post, foreign_key: :member_id

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:name, :website, :approved, :instagram, :facebook, :twitter, :mastodon, :bio, :edit_url])
    |> validate_required([:name, :website, :approved, :instagram, :facebook, :twitter, :mastodon, :bio, :edit_url])
    |> unique_constraint(:edit_url)
  end
end
