defmodule HubWeb.MemberController do
  use HubWeb, :controller
  require Logger
  alias Hub.Auth
  alias Hub.Auth.Member

  def index(conn, _params) do
    members = Auth.list_members()
    render(conn, "index.html", members: members)
	end

  def new(conn, _params) do
    changeset = Auth.change_member(%Member{})
    render(conn, "new.html", changeset: changeset)
	end

	def new_unapproved(conn, _params) do
		changeset = Auth.change_member(%Member{})
		render(conn, "new_unapproved.html", changeset: changeset)
	end

  def create_unapproved(conn, %{"member" => member_params}) do
    if member_params["approved"] == true do
      conn
        |> put_status(:unauthorized)
        |> render(HubWeb.ErrorView, "401.json", message: "Cannot manually approve member.")
		else
			# TODO: we'll need to validate that they're actually uploading images
      case Auth.create_member(member_params) do
				{:ok, member} ->
					# copy over temporary upload to persistent storage
					# if member_params["attachment"] do
					# 	Logger.debug(inspect(member))
					# 	File.cp!(member_params["attachment"].path, "uploads/#{member.path}")
					# end

					if Application.get_env(:hub, :send_emails) do
						Task.async(fn ->
							# TODO: Have there be a list of emails that we'd send to
							Hub.Email.new_member_email(member.name, "me@silentsilas.com")
								|> Hub.Mailer.deliver_now

							# Hub.Email.member_edit_email(member.edit_url, member.email)
							# 	|> Hub.Mailer.deliver_now
						end)
					end

          conn
						|> put_flash(:info, "Member created successfully.")
						|> render("success.html", member: member)

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new_unapproved.html", changeset: changeset)
      end
    end
	end

  def create(conn, %{"member" => member_params}) do
    case Auth.create_member(member_params) do
      {:ok, member} ->
        conn
        |> put_flash(:info, "Member created successfully.")
        |> redirect(to: Routes.member_path(conn, :show, member))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    member = Auth.get_member!(id)
    render(conn, "show.html", member: member)
  end

  def edit(conn, %{"id" => id}) do
    member = Auth.get_member!(id)
    changeset = Auth.change_member(member)
    render(conn, "edit.html", member: member, changeset: changeset)
  end

  def update(conn, %{"id" => id, "member" => member_params}) do
    member = Auth.get_member!(id)

    case Auth.update_member(member, member_params) do
      {:ok, member} ->
        conn
        |> put_flash(:info, "Member updated successfully.")
        |> redirect(to: Routes.member_path(conn, :show, member))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", member: member, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    member = Auth.get_member!(id)
    {:ok, _member} = Auth.delete_member(member)

    conn
    |> put_flash(:info, "Member deleted successfully.")
    |> redirect(to: Routes.member_path(conn, :index))
  end

  def general_show(conn, %{"id" => id}) do
    member = Auth.get_member!(id)
    render(conn, "general_show.html", member: member)
  end

	def general_edit(conn, %{"edit_url" => edit_url}) do
		member = Auth.get_member_by_url(edit_url)
		if member != nil do
			changeset = Auth.change_member(member)
			render(conn, "general_edit.html", member: member, changeset: changeset)
		else
			conn
			|> redirect(to: "/")
		end
	end

	def general_update(conn, %{"id" => id, "member" => member_params}) do
    member = Auth.get_member!(id)

    case Auth.update_member(member, member_params) do
      {:ok, member} ->

        if member_params["attachment"] do
          Logger.debug(inspect(member))
          File.cp!(member_params["attachment"].path, "uploads/#{member.path}")
        end

        conn
        |> put_flash(:info, "Member updated successfully.")
        |> redirect(to: Routes.member_path(conn, :general_edit, member))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "general_edit.html", member: member, changeset: changeset)
    end
  end
end
