defmodule Hub.Content.Post do
	use Ecto.Schema
	require Logger
  import Ecto.Changeset

  schema "posts" do
    field :author, :string
    field :content, :string
		field :title, :string
		field :content_type, :string
    field :filename, :string
    field :path, :string
		field :attachment, :any, virtual: true
		field :approved, :boolean, default: false
		belongs_to :member, Hub.Auth.Member

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:author, :title, :content, :attachment, :approved])
		|> validate_required([:author, :title, :content])
		|> foreign_key_constraint(:member)
		|> put_attachment_file()
	end

	def put_attachment_file(changeset) do

		# first_name = get_field(changeset, :attachment)
		# last_name = get_field(changeset, :last_name)
		# put_change(changeset, :full_name, "#{first_name} #{last_name}")

    case changeset do
      %Ecto.Changeset{changes: %{
        attachment: attachment
      }} ->
				path = Ecto.UUID.generate() <> Path.extname(attachment.filename)
				Logger.debug("did we get here")
				Logger.debug(inspect(attachment))
        changeset
        |> put_change(:path, path)
        |> put_change(:filename, attachment.filename)
        |> put_change(:content_type, attachment.content_type)
      _ ->
        changeset
    end
  end

	def generic_changeset(post, attrs) do
		post
    |> cast(attrs, [:member_id])
	end

end
