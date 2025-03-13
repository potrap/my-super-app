defmodule MySuperAppWeb.HomeLiveTest do
  use MySuperAppWeb.ConnCase
  import Phoenix.LiveViewTest
  alias MySuperApp.{Accounts, CasinosAdmins}

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.register_user(%{
        username: "Super_Admin",
        email: "superadm2in@gmail.com",
        password: "123456789"
      })

    {:ok, role} = CasinosAdmins.create_operator(%{name: "super_operator"})

    user_with_operator = %{user | operator_id: role.id}

    {:ok, conn: log_in_user(conn, user_with_operator)}
  end

  test "renders the HomeLive page", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "Main Features"

    assert html =~ "Chat Room"
    assert html =~ "Engage in real-time conversations with our dynamic Chat Room feature."

    assert html =~ "Admin Page"
    assert html =~ "Manage your site efficiently with our comprehensive Admin Page."

    assert html =~ "Blog Page"

    assert html =~
             "Share your stories, insights, and updates with the world through our engaging Blog Page."

    assert render(view) =~ "href=\"/chatroom\""
    assert render(view) =~ "href=\"/admin\""
    assert render(view) =~ "href=\"/posts\""
  end

  test "Check that the buttons lead to the correct pathse", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render(view) =~ "href=\"/chatroom\""
    assert render(view) =~ "href=\"/admin\""
    assert render(view) =~ "href=\"/posts\""
  end

  test "redirects to the chatroom page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert {:error, {:redirect, %{to: "/chatroom"}}} =
             view |> element("a[href=\"/chatroom\"]") |> render_click()
  end

  test "redirects to the admin page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert {:error, {:redirect, %{to: "/admin"}}} =
             view |> element("a[href=\"/admin\"]") |> render_click()
  end

  test "redirects to the posts page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert {:error, {:redirect, %{to: "/posts"}}} =
             view |> element("a[href=\"/posts\"]") |> render_click()
  end
end
