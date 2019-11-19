defmodule HubWeb.AdminController do
  use HubWeb, :controller

  alias Hub.Auth
  alias Hub.Auth.Admin

  action_fallback HubWeb.FallbackController

  def index(conn, _params) do
    admins = Auth.list_admins()
    render(conn, "index.json", admins: admins)
  end

  def create(conn, %{"admin" => admin_params}) do
    with {:ok, %Admin{} = admin} <- Auth.create_admin(admin_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.admin_path(conn, :show, admin))
      |> render("show.json", admin: admin)
    end
  end

  def show(conn, %{"id" => id}) do
    admin = Auth.get_admin!(id)
    render(conn, "show.json", admin: admin)
  end

  def update(conn, %{"id" => id, "admin" => admin_params}) do
    admin = Auth.get_admin!(id)

    with {:ok, %Admin{} = admin} <- Auth.update_admin(admin, admin_params) do
      render(conn, "show.json", admin: admin)
    end
  end

  def delete(conn, %{"id" => id}) do
    admin = Auth.get_admin!(id)

    with {:ok, %Admin{}} <- Auth.delete_admin(admin) do
      send_resp(conn, :no_content, "")
    end
  end

  def sign_in(conn, %{"username" => username, "password" => password}) do
    case Hub.Auth.authenticate_admin(username, password) do
      {:ok, admin} ->
        conn
        |> put_session(:current_admin_id, admin.id)
        |> redirect(to: "/backstage")

      {:error, message} ->
        conn
        |> delete_session(:current_admin_id)
        |> put_status(:unauthorized)
        |> render(HubWeb.ErrorView, "401.json", message: message)
    end
  end
end
