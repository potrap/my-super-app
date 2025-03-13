defmodule MySuperAppWeb.ChatRoomPageTest do
  use MySuperAppWeb.ConnCase
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    {user, chat} = MySuperApp.ChatFixtures.chat_fixture()

    {:ok, conn: log_in_user(conn, user), chat: chat, user: user}
  end

  test "mounts and renders chat room page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/chatroom")

    assert render(view) =~ "No room has been joined yet"
    assert render(view) =~ "To join a room click on its name on the sidebar to your left."
  end

  test "create room is works", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/chatroom")

    assert render(view) =~ "Communicate room"
  end

  test "entering a chatroom", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/chatroom")

    view
    |> element("a[phx-click=enter-chatroom]")
    |> render_click()

    assert render(view) =~ "Invite code"
    assert render(view) =~ "Regular room"
  end

  test "creating a random room", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/chatroom")

    view
    |> element("button", "Generate New Private Room")
    |> render_click()

    assert_redirected(view, "/chatroom")
  end

  test "receiving a message", %{conn: conn, chat: chat} do
    {:ok, view, _html} = live(conn, "/chatroom")

    view
    |> element("a[phx-click=enter-chatroom][phx-value-id=#{chat.id}]")
    |> render_click()

    message = %{
      "user_email" => "slotsoperator222@gmail.com",
      "timestamp" => "Jan 01, 2024, 12:00:00",
      "body" => "Hello!"
    }

    send(view.pid, {:message, chat.id, message})

    Process.sleep(200)
    assert render(view) =~ "Hello!"
  end

  test "submitting a message", %{conn: conn, chat: chat} do
    {:ok, view, _html} = live(conn, "/chatroom")

    view
    |> element("a[phx-click=enter-chatroom][phx-value-id=#{chat.id}]")
    |> render_click()

    view
    |> form("form", %{"message_body" => "Test message"})
    |> render_submit()

    assert render(view) =~ "Test message"
  end

  test "copy invite code", %{conn: conn, chat: chat} do
    {:ok, view, _html} = live(conn, "/chatroom")

    view
    |> element("a[phx-click=enter-chatroom][phx-value-id=#{chat.id}]")
    |> render_click()

    view
    |> element("svg[phx-click=copy_invite_code_link]")
    |> render_click()

    assert render(view) =~ "copied"
  end

  test "does not submit an empty message", %{conn: conn, chat: chat} do
    {:ok, view, _html} = live(conn, "/chatroom")

    view
    |> element("a[phx-click=enter-chatroom][phx-value-id=#{chat.id}]")
    |> render_click()

    view
    |> form("form", %{"message_body" => ""})
    |> render_submit()

    refute render(view) =~ "Hello!"

    view
    |> form("form", %{"message_body" => "      "})
    |> render_submit()

    refute render(view) =~ "Hello!"
  end

  test "renders multiple chatrooms in sidebar", %{conn: conn, user: user} do
    {:ok, chat1} =
      MySuperApp.Accounts.ChatRooms.create_chatroom(%{
        name: "Communicate room 1",
        description: "Regular room 1",
        user_id: user.id
      })

    {:ok, chat2} =
      MySuperApp.Accounts.ChatRooms.create_chatroom(%{
        name: "Communicate room 2",
        description: "Regular room 2",
        user_id: user.id
      })

    {:ok, view, _html} = live(conn, "/chatroom")

    assert render(view) =~ chat1.name
    assert render(view) =~ chat2.name
  end
end
