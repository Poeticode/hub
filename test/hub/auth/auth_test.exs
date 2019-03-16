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

  describe "members" do
    alias Hub.Auth.Member

    @valid_attrs %{approved: true, bio: "some bio", edit_url: "some edit_url", facebook: "some facebook", instagram: "some instagram", mastodon: "some mastodon", name: "some name", twitter: "some twitter", website: "some website"}
    @update_attrs %{approved: false, bio: "some updated bio", edit_url: "some updated edit_url", facebook: "some updated facebook", instagram: "some updated instagram", mastodon: "some updated mastodon", name: "some updated name", twitter: "some updated twitter", website: "some updated website"}
    @invalid_attrs %{approved: nil, bio: nil, edit_url: nil, facebook: nil, instagram: nil, mastodon: nil, name: nil, twitter: nil, website: nil}

    def member_fixture(attrs \\ %{}) do
      {:ok, member} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_member()

      member
    end

    test "list_members/0 returns all members" do
      member = member_fixture()
      assert Auth.list_members() == [member]
    end

    test "get_member!/1 returns the member with given id" do
      member = member_fixture()
      assert Auth.get_member!(member.id) == member
    end

    test "create_member/1 with valid data creates a member" do
      assert {:ok, %Member{} = member} = Auth.create_member(@valid_attrs)
      assert member.approved == true
      assert member.bio == "some bio"
      assert member.edit_url == "some edit_url"
      assert member.facebook == "some facebook"
      assert member.instagram == "some instagram"
      assert member.mastodon == "some mastodon"
      assert member.name == "some name"
      assert member.twitter == "some twitter"
      assert member.website == "some website"
    end

    test "create_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_member(@invalid_attrs)
    end

    test "update_member/2 with valid data updates the member" do
      member = member_fixture()
      assert {:ok, %Member{} = member} = Auth.update_member(member, @update_attrs)
      assert member.approved == false
      assert member.bio == "some updated bio"
      assert member.edit_url == "some updated edit_url"
      assert member.facebook == "some updated facebook"
      assert member.instagram == "some updated instagram"
      assert member.mastodon == "some updated mastodon"
      assert member.name == "some updated name"
      assert member.twitter == "some updated twitter"
      assert member.website == "some updated website"
    end

    test "update_member/2 with invalid data returns error changeset" do
      member = member_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_member(member, @invalid_attrs)
      assert member == Auth.get_member!(member.id)
    end

    test "delete_member/1 deletes the member" do
      member = member_fixture()
      assert {:ok, %Member{}} = Auth.delete_member(member)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_member!(member.id) end
    end

    test "change_member/1 returns a member changeset" do
      member = member_fixture()
      assert %Ecto.Changeset{} = Auth.change_member(member)
    end
  end
end
