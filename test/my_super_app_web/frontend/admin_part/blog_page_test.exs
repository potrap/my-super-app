defmodule MySuperAppWeb.BlogPageTest do
  use MySuperAppWeb.ConnCase
  import Phoenix.LiveViewTest
  alias MySuperApp.{Accounts, CasinosAdmins, Blog}

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.register_user(%{
        username: "Super_Admin",
        email: "superadmin@gmail.com",
        password: "123456789"
      })

    {:ok, post} =
      Blog.create_post(%{
        "body" => "Special body",
        "title" => "Special title",
        "user_id" => user.id,
        "post_tags" => ["Poker"]
      })

    {:ok, operator} = CasinosAdmins.create_operator(%{name: "super_operator"})

    user_with_operator = %{user | operator_id: operator.id}

    {:ok, conn: log_in_user(conn, user_with_operator), user: user_with_operator, post: post}
  end

  test "mounts successfully with default assigns", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/admin/blog")

    assert html =~ "Blog"
    assert html =~ "Select Author"
    assert html =~ "ID"
    assert html =~ "Title"
  end

  test "searching for real post", %{conn: conn, post: post} do
    {:ok, view, _html} = live(conn, "/admin/blog")

    real_title = post.title

    assert render_hook(view, :change_filter, %{"value" => real_title}) =~ post.title
  end

  test "searching for fake post", %{conn: conn, post: post} do
    {:ok, view, _html} = live(conn, "/admin/blog")

    real_title = "FAKE TITLE"

    refute render_hook(view, :change_filter, %{"value" => real_title}) =~ post.title
  end

  test "searching by id", %{conn: conn, post: post} do
    {:ok, view, _html} = live(conn, "/admin/blog")

    assert render_hook(view, :change_filter, %{"value" => Integer.to_string(post.id)}) =~
             post.title
  end

  test "searching by fake id", %{conn: conn, post: post} do
    {:ok, view, _html} = live(conn, "/admin/blog")

    refute render_hook(view, :change_filter, %{"value" => "23124124124124"}) =~ post.title
  end

  test "delete modal opens correctly", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/blog")

    view
    |> element("button[phx-click=set_open]")
    |> render_click()

    assert render(view) =~ "Are you sure you want to delete post:"
  end

  test "delete modal opens and closes correctly", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/blog")

    view
    |> element("button[phx-click=set_open]")
    |> render_click()

    assert render(view) =~ "Are you sure you want to delete post:"

    view
    |> element("button[phx-click=set_close]")
    |> render_click()

    refute render(view) =~ "Are you sure you want to delete post:"
  end

  test "post delete is working ", %{conn: conn, post: post} do
    {:ok, view, _html} = live(conn, "/admin/blog")

    view
    |> element("button[phx-click=set_open]")
    |> render_click()

    assert render(view) =~ "Are you sure you want to delete post:"
    assert render(view) =~ post.title
    assert render(view) =~ Integer.to_string(post.id)

    view
    |> element("button[phx-click=set_close_confirm]")
    |> render_click()

    refute render(view) =~ "Are you sure you want to delete post:"
    assert render(view) =~ "Post #{post.title} deleted"
    refute render(view) =~ post.body
  end
end
