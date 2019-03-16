defmodule HubWeb.MemberView do
	use HubWeb, :view

	def render("success.json", _) do
    %{
      message: "Successfully submitted post! Please allow 24 hours for an admin to approve it."
    }
  end
end
