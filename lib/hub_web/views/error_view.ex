defmodule HubWeb.ErrorView do
  use HubWeb, :view
  require Logger

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render("401.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  def render("400_post.json", %{changeset: changeset}) do
    Enum.each(changeset.errors, fn ({key, value}) -> 
      Logger.debug(inspect(value)) 
    end)
    %{errors: changeset.errors[:author]}
  end
end
