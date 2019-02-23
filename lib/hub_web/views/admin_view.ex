defmodule HubWeb.AdminView do
  use HubWeb, :view
  alias HubWeb.AdminView

  def render("index.json", %{admins: admins}) do
    %{data: render_many(admins, AdminView, "admin.json")}
  end

  def render("show.json", %{admin: admin}) do
    %{data: render_one(admin, AdminView, "admin.json")}
  end

  def render("admin.json", %{admin: admin}) do
    %{id: admin.id,
      username: admin.username,
      password_hash: admin.password_hash,
      emails: admin.emails}
  end
end
