defmodule MySuperAppWeb.PostLive.Show do
  use MySuperAppWeb, :live_view

  alias MySuperApp.Blog
  alias MySuperApp.Pictures

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def get_name(id), do: MySuperApp.Accounts.get_user(id).username

  def get_tags(id) do
    tags = Blog.get_post(id).tags
    Enum.map(tags, fn x -> x.name end)
  end

  def get_picture_path(id) do
    Pictures.get_picture_by_post(id)
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:post, Blog.get_post!(id))}
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end
