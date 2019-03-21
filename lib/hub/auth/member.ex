defmodule Hub.Auth.Member do
	use Ecto.Schema
	use Arc.Ecto.Schema
	require Logger
  import Ecto.Changeset


  schema "members" do
		field :approved, :boolean, default: false
		field :email, :string
    field :bio, :string
    field :edit_url, :string
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
    |> cast(attrs, [:name, :email, :website, :approved, :instagram, :facebook, :twitter, :mastodon, :bio, :attachment])
		|> check_url_uuid()
		|> cast_attachments(attrs, [:avatar])
		|> validate_required([:name, :email, :approved, :bio, :avatar])
	end

	defp check_url_uuid(changeset) do
    case get_field(changeset, :edit_url) do
      nil ->
        force_change(changeset, :edit_url, Ecto.UUID.generate())
      _ ->
        changeset
    end
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
