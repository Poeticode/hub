defmodule HubWeb.PostView do
	use HubWeb, :view
	import Scrivener.HTML
  alias HubWeb.PostView

  def render("success.json", _) do
    %{
      message: "Successfully submitted post! Please allow 24 hours for an admin to approve it."
    }
  end

  def render("show.json", %{post: post}) do
    render_one(post, PostView, "post.json")
  end

  def render("post.json", %{post: post}) do
    %{
			id: post.id,
      title: post.title,
      content: post.content,
      author: post.author
    }
	end

	def render("index.json", %{posts: posts}) do
		render_many(posts, PostView, "post.json")
	end
end
