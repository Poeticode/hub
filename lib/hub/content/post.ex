defmodule Hub.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset


  schema "posts" do
    field :author, :string
    field :content, :string
    field :title, :string
    field :approved, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:author, :title, :content, :approved])
    |> validate_required([:author, :title, :content])
  end
end
