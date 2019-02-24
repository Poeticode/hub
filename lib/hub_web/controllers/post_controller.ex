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

  def create_unapproved(conn, %{"post" => post_params}) do
    Logger.debug(inspect(post_params))
    if post_params["approved"] == true do
      conn
        |> put_status(:unauthorized)
        |> render(HubWeb.ErrorView, "401.json", message: "Cannot manually approve post.")
    else
      case Content.create_post(post_params) do
        {:ok, post} ->
          conn
          |> put_status(:created)
          |> render("success.json")

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> render(HubWeb.ErrorView, "401.json", message: "Error processing post")
      end
    end
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
end
