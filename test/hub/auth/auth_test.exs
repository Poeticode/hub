defmodule Hub.AuthTest do
  use Hub.DataCase

  alias Hub.Auth

  describe "admins" do
    alias Hub.Auth.Admin

    @valid_attrs %{emails: [], password_hash: "some password_hash", username: "some username"}
    @update_attrs %{emails: [], password_hash: "some updated password_hash", username: "some updated username"}
    @invalid_attrs %{emails: nil, password_hash: nil, username: nil}

    def admin_fixture(attrs \\ %{}) do
      {:ok, admin} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_admin()

      admin
    end

    test "list_admins/0 returns all admins" do
      admin = admin_fixture()
      assert Auth.list_admins() == [admin]
    end

    test "get_admin!/1 returns the admin with given id" do
      admin = admin_fixture()
      assert Auth.get_admin!(admin.id) == admin
    end

    test "create_admin/1 with valid data creates a admin" do
      assert {:ok, %Admin{} = admin} = Auth.create_admin(@valid_attrs)
      assert admin.emails == []
      assert admin.password_hash == "some password_hash"
      assert admin.username == "some username"
    end

    test "create_admin/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_admin(@invalid_attrs)
    end

    test "update_admin/2 with valid data updates the admin" do
      admin = admin_fixture()
      assert {:ok, %Admin{} = admin} = Auth.update_admin(admin, @update_attrs)
      assert admin.emails == []
      assert admin.password_hash == "some updated password_hash"
      assert admin.username == "some updated username"
    end

    test "update_admin/2 with invalid data returns error changeset" do
      admin = admin_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_admin(admin, @invalid_attrs)
      assert admin == Auth.get_admin!(admin.id)
    end

    test "delete_admin/1 deletes the admin" do
      admin = admin_fixture()
      assert {:ok, %Admin{}} = Auth.delete_admin(admin)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_admin!(admin.id) end
    end

    test "change_admin/1 returns a admin changeset" do
      admin = admin_fixture()
      assert %Ecto.Changeset{} = Auth.change_admin(admin)
    end
  end
end
