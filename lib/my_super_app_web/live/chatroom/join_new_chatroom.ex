defmodule MySuperAppWeb.Live.JoinChatRoomView do
  @moduledoc """
  Allows a user to join a room, using the room invite code
  """
  use MySuperAppWeb, :live_view

  alias MySuperApp.Accounts.ChatRooms

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(
        %{"invite_code" => invite_code} = _params,
        _url,
        %{assigns: %{current_user: user}} = socket
      ) do
    chatroom = ChatRooms.get_chatroom_by!(invite_code: invite_code)
    {:ok, _room} = ChatRooms.join(user, chatroom)

    {:noreply,
     socket
     |> put_flash(:info, "ChatRoom #{chatroom.name} successfully joined!")
     |> Phoenix.LiveView.redirect(to: "/chatroom")}
  end

  @impl true
  def render(assigns) do
    ~H"""

    """
  end
end
