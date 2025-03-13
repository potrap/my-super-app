defmodule MySuperAppWeb.SiteControllerTest do
  use MySuperAppWeb.ConnCase

  alias MySuperApp.CasinosAdmins

  @valid_site_attrs %{
    name: "Casino Site",
    key: "unique_key",
    value: 100,
    status: "ACTIVE",
    operator_id: 1,
    image: "site_image.png"
  }

  setup do
    {:ok, operator} = CasinosAdmins.create_operator(%{name: "Operator One"})

    {:ok, site} = CasinosAdmins.create_site(Map.put(@valid_site_attrs, :operator_id, operator.id))

    {:ok, site: site, operator: operator}
  end

  describe "GET /index" do
    test "lists all sites", %{conn: conn} do
      conn = get(conn, ~p"/api/sites")
      assert json_response(conn, 200)["sites"] != []
    end

    test "filters sites by operator name", %{conn: conn, operator: operator} do
      conn = get(conn, ~p"/api/sites", %{"operator_name" => operator.name})
      assert json_response(conn, 200)["sites"] != []
    end
  end

  describe "POST /create" do
    test "creates a site successfully", %{conn: conn, operator: operator} do
      site_params =
        Map.put(@valid_site_attrs, :operator_id, operator.id)
        |> Map.put(:name, "Unique Casino #{System.unique_integer()}")

      conn = post(conn, ~p"/api/sites", %{"site" => site_params})
      assert json_response(conn, 201)["data"]["name"] == site_params.name
    end
  end

  describe "GET /show/:id" do
    test "shows a site", %{conn: conn, site: site} do
      conn = get(conn, ~p"/api/sites/#{site.id}")
      assert json_response(conn, 200)["data"]["id"] == site.id
    end

    test "returns 404 for non-existent site", %{conn: conn} do
      conn = get(conn, ~p"/api/sites/-1")
      assert json_response(conn, 404)["error"] == "Site not found"
    end
  end

  describe "PATCH /update/:id" do
    test "updates a site successfully", %{conn: conn, site: site} do
      update_params = %{"site" => %{name: "Updated Casino"}}
      conn = patch(conn, ~p"/api/sites/#{site.id}", update_params)
      assert json_response(conn, 200)["data"]["name"] == "Updated Casino"
    end
  end

  describe "DELETE /delete/:id" do
    test "deletes a site successfully", %{conn: conn, site: site} do
      conn = delete(conn, ~p"/api/sites/#{site.id}")
      assert response(conn, 204)
    end

    test "returns 404 when deleting non-existent site", %{conn: conn} do
      conn = delete(conn, ~p"/api/sites/-1")
      assert json_response(conn, 404)["error"] == "Site not found"
    end
  end
end
