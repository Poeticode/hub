defmodule Hub.Auth.Member do
	use Ecto.Schema
	use Arc.Ecto.Schema
	require Logger
  import Ecto.Changeset


  schema "members" do
		field :approved, :boolean, default: false
		field :email, :string
		field(:password, :string, virtual: true)
		field(:password_hash, :string)
		field :bio, :string
		field :facebook, :string
		field :instagram, :string
		field :mastodon, :string
		field :name, :string
		field :twitter, :string
		field :website, :string
		field :content_type, :string
		field :filename, :string
		field :path, :string
		field :attachment, :any, virtual: true
		field :avatar, Hub.Avatar.Type
		has_many :posts, Hub.Content.Post, foreign_key: :member_id

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:name, :email, :website, :approved, :instagram, :facebook, :twitter, :mastodon, :bio, :attachment, :password])
		|> cast_attachments(attrs, [:avatar])
    |> validate_required([:name, :email, :approved, :bio, :password])
    |> put_password_hash()
	end

  def pswd_changeset(member, attrs) do
    member
    |> cast(attrs, [:name, :email, :website, :approved, :instagram, :facebook, :twitter, :mastodon, :bio, :attachment, :password])
		|> cast_attachments(attrs, [:avatar])
    |> validate_required([:name, :email, :approved, :bio, :password])
	end

	def pswdless_changeset(member, attrs) do
		member
			|> cast(attrs, [:name, :email, :website, :approved, :instagram, :facebook, :twitter, :mastodon, :bio, :attachment])
			|> cast_attachments(attrs, [:avatar])
			|> validate_required([:name, :email, :approved, :bio])
	end

  defp put_password_hash(
         %Ecto.Changeset{changes: %{password: password}} = changeset
       ) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
	end


end
