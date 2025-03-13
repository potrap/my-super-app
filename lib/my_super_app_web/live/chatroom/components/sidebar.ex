defmodule MySuperAppWeb.Live.Components.Sidebar do
  @moduledoc """
  Side bar component
  """
  use MySuperAppWeb, :live_component

  alias MySuperApp.Accounts.ChatRooms

  @impl true
  def update(
        %{current_user: current_user, current_chatroom_id: current_chatroom_id} = _assigns,
        socket
      ) do
    {:ok,
     assign(socket,
       current_user: current_user,
       user_chatrooms: ChatRooms.get_user_chat_rooms(current_user),
       current_chatroom_id: current_chatroom_id
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-beerus text-indigo-200 w-1/4 pb-6 md:block min-h-screen ">
      <button
        class="bg-popo hover:bg-neutral-700 text-goten px-4 py-2 rounded-lg font-semibold mx-8 my-8"
        phx-click="create_random_room"
      >
        Generate New Private Room
      </button>
      <h1 class="text-black text-xl mb-2 mt-3 px-4 font-sans flex justify-between">
        <span id="text_bold">Secret Chat</span>
      </h1>
      <div class="flex items-center mb-6 px-4">
        <span class="text-black">
          <ul>
            <li>
              <span class="bg-green-500 rounded-full inline-block w-2 h-2 mr-2"></span>
              <%= @current_user.email %>
            </li>
          </ul>
        </span>
      </div>

      <div id="text_bold" class="px-4 mb-2 font-sans text-black">Rooms</div>

      <%= for chatroom <- @user_chatrooms do %>
        <div class="bg-black mb-2 py-1 px-4 text-white font-semi-bold rounded-md mx-4">
          <div class={
            if Integer.to_string(chatroom.id) == @current_chatroom_id, do: "font-bold ", else: ""
          }>
            <a class="link" phx-click="enter-chatroom" phx-value-id={chatroom.id}>
              <span class="pr-1 text-gray-400">#</span> <%= chatroom.name %>
            </a>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
