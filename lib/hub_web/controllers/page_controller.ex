defmodule HubWeb.PageController do
	use HubWeb, :controller
	import Ecto.Query, warn: false

  def index(conn, params) do
		# posts = Hub.Content.list_approved_posts()
		page = Hub.Content.Post
			|> where(approved: true)
			|> Hub.Repo.paginate(params)
    render(conn, "index.html", posts: page.entries, token: get_csrf_token(), page: page)
	end

	def members_index(conn, params) do
		page = Hub.Auth.Member
			|> where(approved: true)
			|> Hub.Repo.paginate(params)
    render(conn, "members.html", members: page.entries, token: get_csrf_token(), page: page)
  end

	def contact(conn, _params) do
		render(conn, "contact.html", body_class: "contact")
	end

  def login(conn, _params) do
    render(conn, "login.html",  token: get_csrf_token(), body_class: "login")
  end

  def admin(conn, _params) do
    render(conn, "admin.html", token: get_csrf_token(), body_class: "admin")
  end
end
