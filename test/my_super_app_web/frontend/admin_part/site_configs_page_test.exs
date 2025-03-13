defmodule MySuperAppWeb.SiteConfigsPageTest do
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

    {:ok, site} =
      CasinosAdmins.create_site(%{
        name: "Live Casino",
        key: "lcs",
        value: 325,
        status: "ACTIVE"
      })

    {:ok, operator} = CasinosAdmins.create_operator(%{name: "super_operator"})

    user_with_operator = %{user | operator_id: operator.id}

    {:ok,
     conn: log_in_user(conn, user_with_operator),
     user: user_with_operator,
     site: site,
     operator: operator}
  end

  test "renders the site configs page successfully", %{conn: conn} do
    conn = get(conn, "/admin/site-configs")
    assert html_response(conn, 200) =~ "Site Configs"
  end

  test "site loaded to page", %{conn: conn, site: site} do
    {:ok, _view, html} = live(conn, "/admin/site-configs")
    assert html =~ site.name
    assert html =~ site.key
    assert html =~ site.status
  end

  test "opens the create site modal", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/site-configs")

    view
    |> element("button[phx-click=open_create_modal]")
    |> render_click()

    assert render(view) =~ "Create New Site Config"
  end

  test "validates and creates a new site", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/site-configs")

    view
    |> element("button[phx-click=open_create_modal]")
    |> render_click()

    view
    |> form("#create_site_modal form",
      site: %{name: "Test Site", key: "test_key", value: 100, status: "ACTIVE"}
    )
    |> render_submit()

    assert render(view) =~ "successfully created"
    assert render(view) =~ "Test Site"
    assert render(view) =~ "test_key"
  end

  test "fails to create site with invalid data", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/admin/site-configs")

    view
    |> element("button[phx-click=open_create_modal]")
    |> render_click()

    view
    |> form("#create_site_modal form", site: %{name: "T", key: "", value: -1, status: "ACTIVE"})
    |> render_submit()

    assert render(view) =~ "Site was already created or length less than 3 or more than 25"
  end

  test "deletes a site", %{conn: conn, site: site} do
    {:ok, view, _html} = live(conn, "/admin/site-configs")

    view
    |> element("button[phx-click=set_open][value=#{site.id}]")
    |> render_click()

    view
    |> element("button[phx-click=set_close_confirm][value=#{site.id}]")
    |> render_click()

    assert render(view) =~ "deleted"
    assert render(view) =~ site.name
    refute render(view) =~ site.key
    refute render(view) =~ site.status
  end

  test "pagination works correctly", %{conn: conn} do
    for x <- 1..15 do
      CasinosAdmins.create_site(%{
        name: "Live Casino#{x}",
        key: "lcs",
        value: 325,
        status: "ACTIVE"
      })
    end

    {:ok, view, _html} = live(conn, "/admin/site-configs")

    assert view
           |> element("button[phx-click=handle_paging_click][value=2]", "2")
           |> render_click()

    assert render(view) =~ "Live Casino6"
    assert render(view) =~ "Live Casino7"
    assert render(view) =~ "Live Casino8"
  end

  test "opens site by clicking open site button", %{conn: conn, site: site} do
    {:ok, view, _html} = live(conn, "/admin/site-configs")
    id = site.id

    assert view
           |> element("button[phx-click=open_site][value=#{id}]")
           |> render_click()

    assert_redirect(view, "/admin/site-configs/site/#{id}")
  end
end
