defmodule MySuperAppWeb.ChatRoomPage do
  @moduledoc false

  use MySuperAppWeb, :live_view
  alias MySuperAppWeb.Live.Components
  alias MySuperApp.Accounts.ChatRooms

  def mount(_, _, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(MySuperApp.PubSub, "chatrooms")
    {:ok, assign(socket, current_chatroom_id: nil)}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="div_mess" class="w-full border shadow bg-white m-auto overflow-auto rounded-lg">
      <div class="flex h-full">
        <.live_component
          module={Components.Sidebar}
          id="sidebar"
          current_user={@current_user}
          current_chatroom_id={@current_chatroom_id}
        />
        <.live_component
          module={Components.Messages}
          id="messages"
          current_user={@current_user}
          chatroom_id={@current_chatroom_id}
        />
      </div>
    </div>
    """
  end

  def handle_event("enter-chatroom", %{"id" => chatroom_id} = _event, socket) do
    {:noreply, assign(socket, current_chatroom_id: chatroom_id)}
  end

  def handle_event("create_random_room", _value, socket) do
    name = Faker.Team.name()
    id = socket.assigns.current_user.id
    ChatRooms.create_chatroom(%{name: name, description: "Another secret chat", user_id: id})

    {:noreply,
     socket
     |> put_flash(:info, "ChatRoom was generated successfully")
     |> redirect(to: ~p"/chatroom")}
  end

  def handle_info({:message, chatroom_id, message}, socket) do
    current_chatroom = socket.assigns.current_chatroom_id

    if current_chatroom && chatroom_id == String.to_integer(current_chatroom) do
      send_update(Components.Messages, id: "messages", new_message: message)
    end

    {:noreply, socket}
  end
end
