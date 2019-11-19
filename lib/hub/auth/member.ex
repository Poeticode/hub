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

	# TODO: Implement this and make sure they only upload images
	def put_attachment_file(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{
        attachment: attachment
      }} ->
				# attrs
				# |> Map.put(:avatar, attachment)
				# %{expenses |
				filename = Ecto.UUID.generate() <> Path.extname(attachment.filename)
				uploads_path = Path.join("uploads", filename)

				Logger.debug(inspect(uploads_path))
				case File.cp!(attachment.path, uploads_path) do
					:ok ->
						mid_path = uploads_path
						 |> Path.absname
						 |> String.replace("\r", "")
						 |> String.replace("\n", "")
						 |> String.replace(":", "")

						new_path = "/" <> mid_path

						Logger.debug(inspect(new_path))

						case Hub.Avatar.store(new_path) do
							{:ok, path} ->
								Logger.debug(inspect(path))
								changeset
									|> put_change(:path, path)
									|> put_change(:filename, attachment.filename)
									|> put_change(:content_type, attachment.content_type)
							{:error, error} ->
								Logger.debug(inspect(error))
								changeset
								|> add_error(:attachment, "error processing attachment")
						end
					_ ->
						changeset
							|> add_error(:attachment, "error processing attachment")
				end


        # changeset
        # |> put_change(:path, path)
        # |> put_change(:filename, attachment.filename)
				# |> put_change(:content_type, attachment.content_type)
				# |> cast_attachments(attrs, [:avatar])
				# Avatar.store("/path/to/my/file.png")
      _ ->
        changeset
    end
  end

end
