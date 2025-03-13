defmodule MySuperAppWeb.UsersPageTest do
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

    {:ok, conn: log_in_user(conn, user_with_operator), current_user: user_with_operator}
  end

  test "renders the Users Page with the list of users", %{conn: conn, current_user: current_user} do
    {:ok, _view, html} = live(conn, "/users")

    assert html =~ current_user.username
    assert html =~ current_user.email
    assert html =~ "Search by username"
  end

  test "filters the list of users by username", %{conn: conn, current_user: current_user} do
    {:ok, view, _html} = live(conn, "/users")

    filter_value = "Super_Admin"

    assert render_hook(view, :change_filter, %{"value" => filter_value}) =~ current_user.username
  end

  test "search name that doesnt exist in the db", %{conn: conn, current_user: current_user} do
    {:ok, view, _html} = live(conn, "/users")

    fake_user = "Sdfsdfjsjdfnsjdngjks"

    refute render_hook(view, :change_filter, %{"value" => fake_user}) =~ current_user.username
  end

  test "open the delete role modal", %{conn: conn, current_user: current_user} do
    {:ok, view, _html} = live(conn, "/users")

    view |> element("button", "Delete role") |> render_click()
    assert render(view) =~ "Are you sure you want your profile #{current_user.username} ?"
  end

  test "modal dooesnt open initially", %{conn: conn, current_user: current_user} do
    {:ok, view, _html} = live(conn, "/users")

    refute render(view) =~ "Are you sure you want your profile #{current_user.username} ?"
  end

  test "pagination button exist", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/users")

    refute view |> element("button", "2") |> has_element?()
    assert view |> element("button", "1") |> has_element?()
  end
end
