defmodule HubWeb.PageController do
  use HubWeb, :controller

  def index(conn, _params) do
    posts = Hub.Content.list_approved_posts()
    render(conn, "index.html", posts: posts, token: get_csrf_token())
  end

  def login(conn, _params) do
    render(conn, "login.html",  token: get_csrf_token(), body_class: "login")
  end

  def admin(conn, _params) do
    render(conn, "admin.html", token: get_csrf_token(), body_class: "admin")
  end
end
