defmodule MySuperAppWeb.OperatorPageTest do
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

  test "renders the operators page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/operators")

    assert render(view) =~ "Operators"
    assert render(view) =~ "Add Operator"
    assert render(view) =~ "ID"
  end

  test "clicking on a row opens the drawer", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/operators")

    view
    |> element("tr[phx-click=open_drawer]")
    |> render_click()

    assert render(view) =~ "Operator information"
  end

  test "drawer closes when Discard button is clicked", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/operators")

    view
    |> element("tr[phx-click=open_drawer]")
    |> render_click()

    view
    |> element("button[phx-click=close_drawer]")
    |> render_click()

    refute render(view) =~ "Operator information"
  end

  test "Update button is enabled for role_id 1", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/operators")

    view
    |> element("tr[phx-click=open_drawer]")
    |> render_click()

    assert element(view, "button[type='submit']")
  end

  test "Create Operator drawer opens", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/operators")

    view
    |> element("button[phx-click=open_drawer_create]")
    |> render_click()

    assert render(view) =~ "Operator create"
    assert render(view) =~ "Operator name"
  end

  test "Create Operator drawer closes when Discard is clicked", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/operators")

    view
    |> element("button[phx-click='open_drawer_create']")
    |> render_click()

    view
    |> element("button[phx-click='on_create_close']", "Discard")
    |> render_click()

    refute render(view) =~ "Create Operator"
    refute render(view) =~ "Operator name"
  end

  test "form validation on operator creation", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/operators")

    view
    |> element("button[phx-click=open_drawer_create]")
    |> render_click()

    view
    |> form("#create_drawer form", operator: %{name: ""})
    |> render_submit()

    assert render(view) =~ "Operator was already created or length less than 3 or more than 25"
  end

  test "operator creation success", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/operators")

    view
    |> element("button[phx-click=open_drawer_create]")
    |> render_click()

    view
    |> form("#create_drawer form", operator: %{name: "New Operator"})
    |> render_submit()

    assert render(view) =~ "Operator successfully created"
  end

  test "delete modal opens when Delete is clicked", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/operators")

    view
    |> element("button[phx-click=modal_open]")
    |> render_click()

    assert render(view) =~ "Delete operator?"
    assert render(view) =~ "Are you sure y wanna delete"
  end

  test "delete modal closes when Discard is clicked", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/operators")

    view
    |> element("button[phx-click=modal_open]")
    |> render_click()

    view
    |> element("button[phx-click=modal_cancel]")
    |> render_click()

    refute render(view) =~ "Delete operator?"
    refute render(view) =~ "Are you sure y wanna delete"
  end

  test "operator deletion success", %{conn: conn, operator: operator} do
    {:ok, view, _html} = live(conn, "/admin/operators")

    view
    |> element("button[phx-click=modal_open]")
    |> render_click()

    view
    |> element("button[phx-click=modal_delete]")
    |> render_click()

    assert render(view) =~ "Operator #{operator.name} deleted"
  end
end
