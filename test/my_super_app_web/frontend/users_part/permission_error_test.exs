defmodule MySuperAppWeb.ErrorPermissionTest do
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

  test "renders Permission Denied message for regular user", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/permission_error")

    assert html =~ "Permission Denied"
    assert html =~ "You are regular user , you dont have access to admin part"
  end

  test "renders GO TO USER PAGE button for regular user", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/permission_error")

    assert html =~ "GO TO USER PAGE"
    assert html =~ "href=\"/users\""
  end

  test "clicking GO TO USER PAGE redirects to /users", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/permission_error")

    assert {:error, {:redirect, %{to: "/users"}}} =
             view |> element("a[href=\"/users\"]") |> render_click()
  end
end
