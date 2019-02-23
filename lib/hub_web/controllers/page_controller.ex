defmodule HubWeb.PageController do
  use HubWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, _params) do
    render(conn, "login.html",  token: get_csrf_token(), body_class: "login")
  end
end
