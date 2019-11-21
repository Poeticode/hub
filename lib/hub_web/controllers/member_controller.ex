defmodule HubWeb.MemberController do
  use HubWeb, :controller
  require Logger
  alias Hub.Auth
  alias Hub.Auth.Member
  import Ecto.Query, warn: false

  def index(conn, _params) do
    members = Auth.list_members()
    render(conn, "index.html", members: members)
	end

  def new(conn, _params) do
    changeset = Auth.change_member(%Member{})
    render(conn, "new.html", changeset: changeset)
	end

  def new_unapproved(conn, _params) do

    changeset = %Member{}
    |> Member.pswd_changeset(%{})

		# changeset = Auth.change_member(new_member)
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

					Task.async(fn ->
						# TODO: Have there be a list of emails that we'd send to
						Hub.Email.new_member_email(member.name, "me@silentsilas.com")
							|> Hub.Mailer.deliver_now

						Hub.Email.member_welcome_email(member.email)
							|> Hub.Mailer.deliver_now

					end)

          conn
						|> put_flash(:info, "Successfully created your account!")
						|> redirect(to: "/login")

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
		changeset = Auth.change_pswdless_member(member)
    render(conn, "edit.html", member: member, changeset: changeset)
  end

  def update(conn, %{"id" => id, "member" => member_params}) do
    member = Auth.get_member!(id)

    case Auth.update_member_pswdless(member, member_params) do
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

  def general_show(conn, %{"id" => id} = params) do
    member = Auth.get_member!(id)
		page = get_own_posts(member, params, true)

		render(conn, "general_show.html", member: member, posts: page.entries, token: get_csrf_token(), page: page)
  end

  def general_edit(conn, _params) do
    current_member_id = get_session(conn, :current_member_id)
    if (current_member_id != nil) do
      member = Auth.get_member!(current_member_id)
      if member != nil do
        changeset = Auth.change_member(member)
        render(conn, "general_edit.html", member: member, changeset: changeset)
      else
        conn
          |> redirect(to: "/")
      end
    else
      conn
        |> redirect(to: "/")
    end
	end

  def general_update(conn, %{"id" => _id,"member" => member_params} = params) do
    current_member_id = get_session(conn, :current_member_id)
		member = Auth.get_member!(current_member_id)
		page = get_own_posts(member, params)

    case Auth.update_member_pswdless(member, member_params) do
      {:ok, member} ->

        if member_params["attachment"] do
          Logger.debug(inspect(member))
          File.cp!(member_params["attachment"].path, "uploads/#{member.path}")
				end

        conn
				|> put_flash(:info, "Member updated successfully.")
				|> redirect(to: Routes.member_path(conn, :dashboard))

			{:error, %Ecto.Changeset{} = changeset} ->
				conn
				|> redirect(to: Routes.member_path(conn, :dashboard, member: member, changeset: changeset, posts: page.entries, token: get_csrf_token(), page: page))
				# |> render("dashboard.html", member: member, changeset: changeset, posts: page.entries, token: get_csrf_token(), page: page)
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Hub.Auth.authenticate_member(email, password) do
      {:ok, member} ->
        conn
        |> put_session(:current_member_id, member.id)
        |> redirect(to: "/member")

      {:error, message} ->
        conn
        |> delete_session(:current_member_id)
        |> put_status(:unauthorized)
        |> render(HubWeb.ErrorView, "401.json", message: message)
    end
  end

  def logout(conn, _params) do
    conn
      |> configure_session(drop: true)
      |> redirect(to: "/")
  end

  def dashboard(conn, params) do
    current_member_id = get_session(conn, :current_member_id)
		member = Auth.get_member!(current_member_id)
		changeset = Auth.change_member(member)
    page = get_own_posts(member, params)

    render(conn, "dashboard.html", member: member, changeset: changeset, posts: page.entries, token: get_csrf_token(), page: page)

	end

	defp get_own_posts(member, params) do
		Hub.Content.Post
			|> where(member_id: ^member.id)
			|> Hub.Repo.paginate(params)
	end

	defp get_own_posts(member, params, _only_approved) do
		Hub.Content.Post
			|> where(member_id: ^member.id)
			|> where(approved: true)
			|> Hub.Repo.paginate(params)
	end

	# Begin Password Reset
	def show_request_reset_password(conn, _params) do
		changeset = Auth.change_token_member()

    render(conn, "password_reset_request.html", changeset: changeset, csrf_token: get_session(conn, :csrf_token))
  end

	def request_reset_password(conn, %{"member" => member_params}) do
    # first we'll need to see if this email has an account
    member = Auth.get_member_by_email(member_params["email"])

		if member do
			new_reset_token = Ecto.UUID.generate()

			member_params =
				Map.put(member_params, "reset_token", new_reset_token)

			member_params =
				Map.put(member_params, "reset_token_timestamp", DateTime.utc_now)

			case Auth.update_member_token(member, member_params) do

				{:ok, member} ->
					# TODO: later down the road, we could queue up emails and batch-send them
					Task.async(fn ->
						Hub.Email.password_reset_email(member_params["email"], new_reset_token)
						|> Hub.Mailer.deliver_now
					end)

					Logger.debug("actually successful")

					conn
						|> put_status(:ok)
						|> render("password_reset_request_success.html")

				{:error, %Ecto.Changeset{} = changeset} ->
					conn
						|> put_status(:ok)
						|> render("password_reset_request_success.html")
			end
    else
      conn
				|> put_status(:ok)
				|> render("password_reset_request_success.html")
    end
	end

	def show_reset_password(conn, %{"token" => token}) do

		member = Auth.get_member_by_token(token)

		if member do
			# now check to see if token has expired or not
			current_time = DateTime.utc_now()
			elapsed_seconds = DateTime.diff(current_time, member.reset_token_timestamp)

			# We'll see if it's been no longer than 6 hours
			if elapsed_seconds < 60 * 60 * 6 do
				changeset = Auth.change_only_pswd(member)
				render(conn, "password_reset.html", changeset: changeset, member: member, csrf_token: get_session(conn, :csrf_token), token: token)
			else
				conn
					|> render("password_reset_fail.html")
			end
		else
			conn
				|> render("password_reset_fail.html")
		end
	end

	def reset_password(conn, %{
			"token" => token,
			"member" => params
		}) do

		member = Auth.get_member_by_token(token)

		if member do
			# now check to see if token has expired or not
			current_time = DateTime.utc_now()
			elapsed_seconds = DateTime.diff(current_time, member.reset_token_timestamp)

			if elapsed_seconds < 60 * 60 * 6 do
				member_params = %{
					password: params["password"],
					reset_token: nil
				}
				case Auth.update_member_reset_pswd(member, member_params) do
					{:ok, %Member{} = member} ->
						render(conn, "password_reset_success.html")
					{:error, %Ecto.Changeset{} = changeset} ->
						Logger.debug(inspect(changeset))
						render(conn, "password_reset.html", member: member, changeset: changeset, csrf_token: get_session(conn, :csrf_token), token: token)
				end
			else
				render(conn, "password_reset_fail.html")
			end
		else
			render(conn, "password_reset_fail.html")
		end
	end

end
