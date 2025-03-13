defmodule MySuperAppWeb.RolesPageTest do
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
    {:ok, role} = CasinosAdmins.create_role(%{name: "Test role", operator_id: operator.id})

    user_with_operator = %{user | operator_id: operator.id}

    {:ok,
     conn: log_in_user(conn, user_with_operator),
     user: user_with_operator,
     fake_user: fake_user,
     role: role,
     operator: operator}
  end

  test "loads the roles page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/admin/roles")
    assert html =~ "Roles"
    assert html =~ "Add Role"
    assert html =~ "Select Operator"
  end

  test "opens create role modal", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/roles")

    view
    |> element("button[phx-click=open_create_modal]")
    |> render_click()

    assert render(view) =~ "Create new Role"
  end

  test "validates role name in create role modal", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/roles")

    view
    |> element("button[phx-click=open_create_modal]")
    |> render_click()

    view
    |> form("#create_role_modal form", role: %{"name" => "A"})
    |> render_submit()

    assert render(view) =~ "Role was already created or length less than 3 or more than 25"
  end

  test "creates a new role", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/roles")

    view
    |> element("button[phx-click=open_create_modal]")
    |> render_click()

    view
    |> form("#create_role_modal form", role: %{"name" => "NewRole"})
    |> render_submit()

    assert render(view) =~ "Role successfully created"
  end

  test "opens drawer when clicking table row", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/roles")

    view
    |> element("tr[phx-click=open_drawer]")
    |> render_click()

    assert render(view) =~ "Role information"
  end

  test "discards changes in drawer", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/roles")

    view
    |> element("tr[phx-click=open_drawer]")
    |> render_click()

    view
    |> element("button[phx-click=close_drawer]")
    |> render_click()

    refute render(view) =~ "Role information"
  end

  test "opens delete confirmation modal", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/roles")

    view
    |> element("button[phx-click=set_open]")
    |> render_click()

    assert render(view) =~ "Are you sure you want to delete role"
  end

  test "cancels delete action", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/roles")

    view
    |> element("button[phx-click=set_open]")
    |> render_click()

    view
    |> element("button[phx-click=set_close]")
    |> render_click()

    refute render(view) =~ "Are you sure you want to delete role"
  end

  test "confirms delete action", %{conn: conn, role: role} do
    {:ok, view, _html} = live(conn, "/admin/roles")

    view
    |> element("button[phx-click='set_open']")
    |> render_click()

    view
    |> element("button[phx-click='set_close_confirm']")
    |> render_click()

    assert render(view) =~ "Role #{role.name} deleted"
  end

  test "paggination work correctly", %{conn: conn, operator: operator} do
    Enum.map(1..20, fn n ->
      CasinosAdmins.create_role(%{name: "Test role#{n}", operator_id: operator.id})
    end)

    {:ok, view, _html} = live(conn, "/admin/roles")

    view
    |> element("button[phx-click=handle_paging_click]", "2")
    |> render_click()

    assert render(view) =~ "Test role5"
    assert render(view) =~ "Test role6"
    assert render(view) =~ "Test role7"
  end

  test "searching for fake name", %{conn: conn, role: role} do
    {:ok, view, _html} = live(conn, "/admin/roles")

    fake_name = "Sdfsdfjsjdfnsjdngjks"

    refute render_hook(view, :change_filter, %{"value" => fake_name}) =~ role.name
  end

  test "searching for real name", %{conn: conn, role: role} do
    {:ok, view, _html} = live(conn, "/admin/roles")

    real_role = role.name

    assert render_hook(view, :change_filter, %{"value" => real_role}) =~ role.name
  end
end
