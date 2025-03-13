defmodule MySuperAppWeb.Live.Components.Messages do
  @moduledoc """
  Side bar component
  """
  use MySuperAppWeb, :live_component

  alias MySuperApp.Accounts.ChatRooms

  @impl true
  def update(%{chatroom_id: nil} = _assigns, socket) do
    {:ok, assign(socket, chatroom: nil)}
  end

  @impl true
  def update(%{id: id, current_user: current_user, chatroom_id: chatroom_id} = _assigns, socket) do
    {:ok,
     assign(socket,
       id: id,
       chatroom: ChatRooms.get_chatroom!(chatroom_id),
       invite_link_copied: false,
       messages: [],
       current_user: current_user
     )
     |> push_event("load_messages", %{chatroom_id: chatroom_id})}
  end

  @impl true
  def update(%{new_message: message} = _assigns, socket) do
    messages = socket.assigns.messages ++ [message]

    {:ok,
     socket
     |> assign(messages: messages)
     |> push_event(
       "new_message",
       %{
         chatroom_id: socket.assigns.chatroom.id,
         field_id: "message_body",
         message: message
       }
     )}
  end

  @impl true
  def render(%{chatroom: nil} = assigns) do
    ~H"""
    <div class="w-full flex flex-col text-center pt-36 font-bold ">
      No room has been joined yet. To join a room click on its name on the sidebar to your left.
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="w-full flex flex-col rounded-md" phx-hook="LoadMessagesFromLocalStorage">
      <div class="flex justify-between border-b-4 border-stone-700 pb-4 pt-4 px-8">
        <h1 class="font-bold text-xl"><%= @chatroom.name %></h1>
        <h1><%= @chatroom.description %></h1>
        <div class="text-grey-800 text-md link">
          Invite code: <%= @chatroom.invite_code %>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-6 w-6 inline link"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            phx-click="copy_invite_code_link"
            phx-value-code={@chatroom.invite_code}
            phx-target={@myself}
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
            />
          </svg>
          <%= if @invite_link_copied do %>
            copied
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6 inline"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M5 13l4 4L19 7"
              />
            </svg>
          <% end %>
        </div>
      </div>
      <div class="flex-1 overflow-scroll-x px-8 py-8">
        <%= for message <- @messages do %>
          <div class="flex items-start mb-4 ml-8">
            <div class="flex flex-col">
              <div class="flex items-end">
                <span class="font-bold text-md mr-2 font-sans"><%= message["user_email"] %></span>
                <span class="text-gray-500 text-xs font-400"><%= message["timestamp"] %></span>
              </div>
              <p class="font-400 text-md text-gray-800 pt-1"><%= message["body"] %></p>
            </div>
          </div>
        <% end %>
      </div>

      <.form for={%{}} as={:message} phx-submit="submit" phx-target={@myself} class="px-8 pb-8">
        <input type="text" name="message_body" class="rounded-md w-1/3 mr-4" />
        <button
          type="submit"
          class="px-6 py-2 bg-black hover:bg-neutral-700 text-white font-bold rounded-lg shadow-md focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75"
        >
          Send Message
        </button>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("copy_invite_code_link", %{"code" => code}, socket) do
    link = MySuperAppWeb.Endpoint.url() <> "/rooms/join/#{code}"

    {:noreply,
     socket
     |> assign(invite_link_copied: true)
     |> push_event("copy_invite_code_link", %{link: link})}
  end

  @impl true
  def handle_event("submit", %{"message_body" => message_body}, socket) do
    if String.trim(message_body) == "" do
      {:noreply, socket}
    else
      message = %{
        "user_email" => socket.assigns.current_user.email,
        "timestamp" => format_time(DateTime.now!("Etc/UTC")),
        "body" => message_body
      }

      Phoenix.PubSub.broadcast(
        MySuperApp.PubSub,
        "chatrooms",
        {:message, socket.assigns.chatroom.id, message}
      )

      {:noreply, socket |> push_event("clear_input", %{field_id: "message_body"})}
    end
  end

  def handle_event("load-messages", nil, socket) do
    {:noreply, socket |> assign(messages: [])}
  end

  def handle_event("load-messages", messages, socket) do
    {:noreply, socket |> assign(messages: messages)}
  end

  defp format_time(time) do
    time
    |> Timex.shift(hours: 3)
    |> Timex.format!("%b %d, %Y, %H:%M:%S", :strftime)
  end
end
