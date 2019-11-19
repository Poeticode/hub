defmodule HubWeb.Router do
  use HubWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HubWeb do
    pipe_through :browser

    get "/", PageController, :index
		get "/contact", PageController, :contact
    get "/backstage", PageController, :backstage
    post "/backstage", AdminController, :sign_in

    get "/login", PageController, :login
    post "/login", MemberController, :sign_in

    get "/logout", MemberController, :logout

		get "/submissions/:id", PostController, :general_show
    get "/members", PageController, :members_index
    get "/members/:id", MemberController, :general_show

		get "/signup", MemberController, :new_unapproved
		post "/signup", MemberController, :create_unapproved
	end

	scope "/api", HubWeb do
		pipe_through :api

		get "/submissions", PostController, :api_search
  end

  scope "/member", HubWeb do
    pipe_through [:browser, :ensure_member]

    get "/", MemberController, :dashboard
		put "/update/:id", MemberController, :general_update
		patch "/update/:id", MemberController, :general_update
    get "/new_submission", PostController, :new_attributed
    post "/new_submission", PostController, :create_attributed
  end

  scope "/backstage", HubWeb do
    pipe_through [:browser, :ensure_admin]

		resources "/posts", PostController
		resources "/members", MemberController
  end

  defp ensure_admin(conn, _opts) do
    current_admin_id = get_session(conn, :current_admin_id)
    if current_admin_id do
      conn
    else
      deny_access(conn)
    end
  end

  defp ensure_member(conn, _opts) do
    current_member_id = get_session(conn, :current_member_id)
    if current_member_id do
      conn
    else
      deny_access(conn)
    end
  end

  defp deny_access(conn) do
    conn
      |> put_status(:unauthorized)
      |> render(HubWeb.ErrorView, "401.json", message: "Unauthenticated account")
  end
end
