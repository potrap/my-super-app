defmodule MySuperApp.MailWorker do
  @moduledoc false

  @mailjet_api_key "5b2f2ff8a6a6d0d25c6c7dbde6a6fe1c"
  @mailjet_secret_key "2e577ed409abda8c4f9087660affb667"

  def send_email(email, content) do
    body = %{
      "Messages" => [
        %{
          "From" => %{"Email" => "potrapmax@gmail.com"},
          "To" => [%{"Email" => email}],
          "Subject" => "Important Notification",
          "TextPart" => content
        }
      ]
    }

    headers = [
      {"Authorization", "Basic " <> Base.encode64("#{@mailjet_api_key}:#{@mailjet_secret_key}")},
      {"Content-Type", "application/json"}
    ]

    body_json = Jason.encode!(body)

    case Tesla.post("https://api.mailjet.com/v3.1/send", body_json, headers: headers) do
      {:ok, _response} -> :ok
      {:error, _reason} -> :error
    end
  end

  def notify_admins_about_new_user(user) do
    admin_emails = ["valsorayaroslav@gmail.com", "admin1111@admin11111"]

    content = "A new user has been registered: #{user.email}"

    for admin_email <- admin_emails do
      send_email(admin_email, content)
    end
  end
end
