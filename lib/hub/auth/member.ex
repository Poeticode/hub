defmodule Hub.Auth.Member do
	use Ecto.Schema
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
		# field :filename, :string
    # field :path, :string
		# field :attachment, :any, virtual: true
		has_many :posts, Hub.Content.Post, foreign_key: :member_id

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:name, :email, :website, :approved, :instagram, :facebook, :twitter, :mastodon, :bio])
		|> validate_required([:name, :email, :approved, :bio])
		|> check_url_uuid()
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
				path = Ecto.UUID.generate() <> Path.extname(attachment.filename)
				Logger.debug(inspect(attachment))
        changeset
        |> put_change(:path, path)
        |> put_change(:filename, attachment.filename)
        |> put_change(:content_type, attachment.content_type)
      _ ->
        changeset
    end
  end

end
