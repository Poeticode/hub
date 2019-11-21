defmodule Hub.Mailer do
	use Bamboo.Mailer, otp_app: :hub
end

defmodule Hub.Email do
	import Bamboo.Email
	import Bamboo.SendGridHelper
	require Logger

	def new_submission_email(title, author, post_id, recipient) do
		site_url = Application.get_env(:hub, :site_url)
		base_email()
		|> to(recipient)
		|> with_template(Application.get_env(:hub, :sendgrid_submission_id))
		|> add_dynamic_field(:url, "#{site_url}backstage")
		|> add_dynamic_field(:title, title)
		|> add_dynamic_field(:author, author)
	end

	def new_member_email(name, recipient) do
		site_url = Application.get_env(:hub, :site_url)
		base_email()
		|> to(recipient)
		|> with_template(Application.get_env(:hub, :sendgrid_member_template_id))
		|> add_dynamic_field(:name, name)
		|> add_dynamic_field(:url, "#{site_url}backstage")
		|> add_dynamic_field(:site_name, "Poetry, Pups, and Pints")
	end

	def member_welcome_email(recipient) do
		site_url = Application.get_env(:hub, :site_url)
		base_email()
		|> to(recipient)
		|> with_template(Application.get_env(:hub, :sendgrid_welcome_member_template_id))
		|> add_dynamic_field(:url, "#{site_url}login")
	end

	def password_reset_email(recipient, token) do
		site_url = "#{Application.get_env(:hub, :site_url)}reset-password/#{token}"
		base_email()
			|> to(recipient)
			|> with_template(Application.get_env(:hub, :sendgrid_reset_password_template_id))
			|> add_dynamic_field(:url, site_url)
			|> add_dynamic_field(:site_name, "Poetry, Pups, and Pints")
	end

	defp base_email do
    new_email
    |> from("Poetry, Pups, and Pints <me@silentsilas.com>")
    # This will use the "email.html.eex" file as a layout when rendering html emails.
    # Plain text emails will not use a layout unless you use `put_text_layout`
    # |> put_html_layout({Myapp.LayoutView, "email.html"})
  end
end
