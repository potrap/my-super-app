defmodule MySuperAppWeb.AdminPageTest do
  use MySuperAppWeb.ConnCase
  import Phoenix.LiveViewTest
  alias MySuperApp.{Accounts, CasinosAdmins}

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.register_user(%{
        username: "Super_Admin",
        email: "superadmin@gmail.com",
        password: "123456789"
      })

    {:ok, fake_user} =
      Accounts.register_user(%{
        username: "Fake_User",
        email: "fake_user@gmail.com",
        password: "123456789"
      })

    {:ok, operator} = CasinosAdmins.create_operator(%{name: "super_operator"})
    {:ok, _role} = CasinosAdmins.create_role(%{name: "Test role"})

    user_with_operator = %{user | operator_id: operator.id}

    {:ok,
     conn: log_in_user(conn, user_with_operator), user: user_with_operator, fake_user: fake_user}
  end

  test "renders Operator content if operator_id is not nil", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin/users/")

    assert html =~ "Users"
    assert html =~ "ID"
    assert html =~ "Username"
    assert html =~ "Email"
    assert html =~ "Registred at"
  end

  test "Users displayed correctly", %{conn: conn, user: user, fake_user: fake_user} do
    {:ok, view, _html} = live(conn, ~p"/admin/users/")

    assert render(view) =~ user.username
    assert render(view) =~ user.email
    assert render(view) =~ fake_user.username
    assert render(view) =~ fake_user.email
  end

  test "open dropdown and show roles", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/users/")

    assert has_element?(view, "div[phx-click]", "Select users by role")

    element(view, "div[phx-click]", "Select users by role")
    |> render_click()

    assert render(view) =~ "Test role"
    assert render(view) =~ "Select users by role"
  end

  test "check if filter by role is work ", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, ~p"/admin/users/")

    refute render_hook(view, :option_send, %{"value" => "Test role"}) =~ user.username
  end

  test "check if filter show all roles is works ", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, ~p"/admin/users/")

    assert render_hook(view, :option_send_all, %{"value" => "fake"}) =~ user.username
  end

  test "delete user", %{conn: conn, fake_user: fake_user} do
    {:ok, view, _html} = live(conn, "/admin/users/")

    view
    |> element("button[value=#{fake_user.id}]", "Delete user")
    |> render_click()

    view
    |> element("button[phx-click=set_close_confirm]", "Confirm")
    |> render_click()

    assert render(view) =~ "User #{fake_user.username} deleted"
    refute render(view) =~ fake_user.email
  end

  test "operator update drawer opens correctly", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, "/admin/users/")

    render_hook(view, :open_drawer_operator, %{"value" => user.id})

    assert render(view) =~ "Delete Operator Permission"
    assert render(view) =~ "User information"
    assert render(view) =~ "Update"
  end

  test "operator update drawer closes correctly", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, "/admin/users/")

    render_hook(view, :open_drawer_operator, %{"value" => user.id})

    assert render(view) =~ "Delete Operator Permission"
    assert render(view) =~ "User information"
    assert render(view) =~ "Update"

    render_hook(view, :close_drawer_operator)

    refute render(view) =~ "Delete Operator Permission"
    refute render(view) =~ "User information"
    refute render(view) =~ "Update"
  end

  test "role update drawer opens correctly", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, "/admin/users/")

    render_hook(view, :open_drawer, %{"value" => user.id})

    assert render(view) =~ "Delete Role"
    assert render(view) =~ "Update Role"
    assert render(view) =~ "User information"
  end

  test "role update drawer closes correctly", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, "/admin/users/")

    render_hook(view, :open_drawer, %{"value" => user.id})

    assert render(view) =~ "Delete Role"
    assert render(view) =~ "Update Role"
    assert render(view) =~ "User information"

    render_hook(view, :close_drawer)

    refute render(view) =~ "Delete Role"
    refute render(view) =~ "Update Role"
    refute render(view) =~ "User information"
  end

  test "paggination work correctly", %{conn: conn, user: user} do
    Enum.map(1..20, fn n ->
      Accounts.register_user(%{
        username: "FakeUser#{n}",
        email: "fakeuser#{n}@gmail.com",
        password: "123456789"
      })
    end)

    {:ok, view, _html} = live(conn, "/admin/users/")

    view
    |> element("button[phx-click=handle_paging_click]", "2")
    |> render_click()

    assert render(view) =~ "fakeuser5@gmail.com"
    refute render(view) =~ "fakeuser1@gmail.com"
    refute render(view) =~ user.email
    refute render(view) =~ "Fake_User"
  end

  test "searching for real name", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, "/admin/users")

    real_user = user.username

    assert render_hook(view, :change_filter, %{"value" => real_user}) =~ user.username
  end
end
