defmodule Hub.Auth.Admin do
  use Ecto.Schema
  import Ecto.Changeset


  schema "admins" do
    field :emails, {:array, :string}
    field :password, :string, virtual: true
    field :password_hash, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [:username, :password, :emails])
    |> validate_required([:username, :password, :emails])
    |> put_password_hash()
  end

  defp put_password_hash(
    %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
  ) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset) do
    changeset
  end
end
