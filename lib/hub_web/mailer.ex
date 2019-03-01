defmodule Hub.Mailer do
	use Bamboo.Mailer, otp_app: :hub
end

defmodule Hub.Email do
	import Bamboo.Email
	import Bamboo.SendGridHelper
	require Logger

	def new_submission_email(title, author, post_id, recipient) do
		base_email()
		|> to(recipient)
		|> with_template(Application.get_env(:hub, :sendgrid_template_id))
		|> add_dynamic_field(:url, "localhost:4000/admin/posts/#{post_id}")
		|> add_dynamic_field(:title, title)
		|> add_dynamic_field(:author, author)
	end

	defp base_email do
    new_email
    |> from("Collective <me@silentsilas.com>")
    # This will use the "email.html.eex" file as a layout when rendering html emails.
    # Plain text emails will not use a layout unless you use `put_text_layout`
    # |> put_html_layout({Myapp.LayoutView, "email.html"})
  end
end
