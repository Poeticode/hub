defmodule HubWeb.PostView do
  use HubWeb, :view
  alias HubWeb.PostView

  def render("show.json", %{post: post}) do
    render_one(post, PostView, "post.json")
  end

  def render("post.json", %{post: post}) do
    %{title: post.title,
      content: post.content,
      author: post.author}
  end
end
