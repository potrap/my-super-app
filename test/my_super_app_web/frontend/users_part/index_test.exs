defmodule MySuperAppWeb.PostLive.IndexTest do
  use MySuperAppWeb.ConnCase
  import Phoenix.LiveViewTest
  alias MySuperApp.{Accounts, CasinosAdmins, Blog}

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.register_user(%{
        username: "Super_Admin",
        email: "superadm2in@gmail.com",
        password: "123456789"
      })

    {:ok, role} = CasinosAdmins.create_operator(%{name: "super_operator"})

    user_with_operator = %{user | operator_id: role.id}

    {:ok, post} =
      Blog.create_post(%{
        "body" => "some body",
        "title" => "some title",
        "user_id" => user.id,
        "post_tags" => ["Poker"]
      })

    {:ok,
     conn: log_in_user(conn, user_with_operator), current_user: user_with_operator, post: post}
  end

  test "renders posts index page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/posts")
    assert html =~ "Blog"
    assert html =~ "Title"
    assert html =~ "Author"
  end
end
