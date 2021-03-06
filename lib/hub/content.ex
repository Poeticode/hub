defmodule Hub.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias Hub.Repo

  alias Hub.Content.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Returns all posts that have been approved by admin.
  """
  def list_approved_posts do
    Post
    |> where(approved: true)
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  def get_post(id) do
    Repo.get(Post, id)
  end
  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

	def update_post_assoc(%Post{} = post, member) do
    post
    |> Post.generic_changeset(%{})
    |> Ecto.Changeset.put_change(:member_id, member.id)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
	end

	def search_posts(query) do
		Repo.all from p in Post,
			where: ilike(p.title, ^"%#{String.replace(query, "%", "\\%")}%") or
						 ilike(p.content, ^"%#{String.replace(query, "%", "\\%")}%") or
						 ilike(p.author, ^"%#{String.replace(query, "%", "\\%")}%")
	end

	def search_posts_by_title(query) do
		Repo.all from p in Post,
			where: ilike(p.title, ^"%#{String.replace(query, "%", "\\%")}%")
	end

	def search_posts_by_content(query) do
		Repo.all from p in Post,
			where: ilike(p.content, ^"%#{String.replace(query, "%", "\\%")}%")
	end

	def search_posts_by_author(query) do
		Repo.all from p in Post,
			where: ilike(p.author, ^"%#{String.replace(query, "%", "\\%")}%")
	end
end
