defmodule HubWeb.PostController do
  use HubWeb, :controller
  require Logger
  alias Hub.Content
  alias Hub.Content.Post
  action_fallback HubWeb.FallbackController

  def index(conn, _params) do
    posts = Content.list_posts()
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Content.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
	end

	def new_unapproved(conn, _params) do
		changeset = Content.change_post(%Post{})
		render(conn, "new_unapproved.html", changeset: changeset)
	end

  def create_unapproved(conn, %{"post" => post_params}) do
    Logger.debug(inspect(post_params))
    if post_params["approved"] == true do
      conn
        |> put_status(:unauthorized)
        |> render(HubWeb.ErrorView, "401.json", message: "Cannot manually approve post.")
		else
			# TODO: we'll need to validate that they're actually uploading images
      case Content.create_post(post_params) do
				{:ok, post} ->
					# copy over temporary upload to persistent storage
					if post_params["attachment"] do
						Logger.debug(inspect(post))
						File.cp!(post_params["attachment"].path, "uploads/#{post.path}")
					end

					Task.async(fn ->
						# TODO: Have there be a list of emails that we'd send to
						Hub.Email.new_submission_email(post.title, post.author, post.id, "me@silentsilas.com")
							|> Hub.Mailer.deliver_now
					end)

          conn
						|> put_flash(:info, "Post created successfully.")
						|> render("success.html", post: post)

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new_unapproved.html", changeset: changeset)
      end
    end
	end

	def success(conn, %{"id" => id}) do
		post = Content.get_post!(id)
		render(conn, "success.html", post: post)
	end

  def create(conn, %{"post" => post_params}) do

    case Content.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Content.get_post!(id)
    render(conn, "show.html", post: post)
  end

  def general_show(conn, %{"id" => id}) do
    post =  Content.get_post(id)
    if post != nil do
      if post.approved == true do
        conn
        |> render("general_show.html", post: post)
      else
        conn
        |> render(HubWeb.ErrorView, "401.json", message: "Couldn't find post")
      end
    else
      conn
      |> render(HubWeb.ErrorView, "401.json", message: "Couldn't find post")
    end
  end

  def edit(conn, %{"id" => id}) do
    post = Content.get_post!(id)
    changeset = Content.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Content.get_post!(id)

    case Content.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Content.get_post!(id)
    {:ok, _post} = Content.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.post_path(conn, :index))
	end

	# def api_search(conn, %{"query" => query}) do
	# 	posts = Content.search_posts(query)
	# 	render(conn, "index.json", posts: posts)
	# end

	def api_search(conn, %{"query" => query, "type" => type}) do
		case type do
			"all" ->
				posts = Content.search_posts(query)
				render(conn, "index.json", posts: posts)
			"author" ->
				posts = Content.search_posts_by_author(query)
				render(conn, "index.json", posts: posts)
			"title" ->
				posts = Content.search_posts_by_title(query)
				render(conn, "index.json", posts: posts)
			"content" ->
				posts = Content.search_posts_by_content(query)
				render(conn, "index.json", posts: posts)
			_ ->
				render(conn, HubWeb.ErrorView, "403.json", message: "Invalid type to search by.")
		end
	end

end
